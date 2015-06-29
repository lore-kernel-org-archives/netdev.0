From: Conrad Hoffmann <ch@bitfehler.net>
Subject: Re: [PATCH RFC] net/unix: SO_REUSEPORT for AF_UNIX
Date: Mon, 29 Jun 2015 13:17:04 +0200
Message-ID: <55912930.7040409@bitfehler.net>
References: <1435485139-16866-1-git-send-email-ch@bitfehler.net>
 <CALCkm3f2uvsCn=uiyCqrR_V=CgCpU-TSGYH6JTkcm6QQV5FdVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from osk4r.t3rror.net ([5.9.43.3]:52244 "EHLO mail.t3rror.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753007AbbF2LSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 07:18:05 -0400
In-Reply-To: <CALCkm3f2uvsCn=uiyCqrR_V=CgCpU-TSGYH6JTkcm6QQV5FdVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 06/29/2015 06:05 AM, Alex Gartrell wrote:
> On Sun, Jun 28, 2015 at 2:52 AM, Conrad Hoffmann <ch@bitfehler.net> wrote:
>> Support the SO_REUSEPORT option for AF_UNIX (aka AF_LOCAL) sockets. Note
>> that unlike the IP implementations, the semantics for AF_UNIX sockets are
>> those of the original BSD implementation, i.e. each socket that
>> successfully reuses a port completely takes over from the previous
>> listener.
> 
> This is a really weird corner case from a user's perspective.  I think
> sharing it is more reasonable, as you can always signal the other
> process out of band.

Thanks for the feedback. While I don't think the use case is that weird I
understand that the shared solution would accomodate for both this and
other use case, thus being the superior one. I'll see what I can do.

Conrad
