From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH RFC] net/unix: SO_REUSEPORT for AF_UNIX
Date: Sun, 28 Jun 2015 21:05:22 -0700
Message-ID: <CALCkm3f2uvsCn=uiyCqrR_V=CgCpU-TSGYH6JTkcm6QQV5FdVA@mail.gmail.com>
References: <1435485139-16866-1-git-send-email-ch@bitfehler.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Conrad Hoffmann <ch@bitfehler.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:33349 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbbF2EFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 00:05:42 -0400
Received: by qgem68 with SMTP id m68so14122742qge.0
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2015 21:05:41 -0700 (PDT)
In-Reply-To: <1435485139-16866-1-git-send-email-ch@bitfehler.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 28, 2015 at 2:52 AM, Conrad Hoffmann <ch@bitfehler.net> wrote:
> Support the SO_REUSEPORT option for AF_UNIX (aka AF_LOCAL) sockets. Note
> that unlike the IP implementations, the semantics for AF_UNIX sockets are
> those of the original BSD implementation, i.e. each socket that
> successfully reuses a port completely takes over from the previous
> listener.

This is a really weird corner case from a user's perspective.  I think
sharing it is more reasonable, as you can always signal the other
process out of band.

-- 
Alex Gartrell
