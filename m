From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/2] net: convert lists of macros to
 enumerations
Date: Mon, 24 Jun 2013 08:14:14 -0700
Message-ID: <20130624081414.492ceeb0@nehalam.linuxnetplumber.net>
References: <1372024577-6343-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:55089 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab3FXPOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 11:14:19 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so11219369pad.30
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:14:19 -0700 (PDT)
In-Reply-To: <1372024577-6343-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jun 2013 15:56:16 -0600
Jean Sacren <sakiwit@gmail.com> wrote:

> Use enumerations to replace macros for simpler preprocessing. Map numeric
> values to enumerators. Where required, prepend the list with an additional
> enumerator to accommodate the rest.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Converting the network based header files is easy and safe as long
as you test it. Not sure if it is worth the effort.

But changing the uapi exported header risks breaking applications that
were doing:

#ifdef SIOCXXXX
       do some code to enable that
#endif

Since enum values don't show up in the CPP namespace.
