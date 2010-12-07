From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird network problem - stalls, reload works
Date: Tue, 07 Dec 2010 20:20:57 +0100
Message-ID: <4CFE8919.3030000@gmail.com>
References: <4CFC17B8.4050908@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36441 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796Ab0LGTVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 14:21:05 -0500
Received: by wwi17 with SMTP id 17so1267848wwi.1
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 11:21:03 -0800 (PST)
In-Reply-To: <4CFC17B8.4050908@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Tokarev wrote:
> Hello.
Hi,
> 
> I've a weird networking problem here, which I'm
> trying to hunt for some time.
...
> So I'm quite stuck here, and don't know what to do next.
> My next bet is to try another motherboard, in a hope that
> this is just some broken interrupt controller, but it is
> a bit too unreal...
> 
> Any hints on what to try are greatly apprecated...

You might try the usual stuff like in linux-2.6/REPORTING-BUGS ;-)
Plus maybe some debugging turned on in the config (DMA?) and
driver (s/#if 0/#if 1/ around line 69 in forcedeth.c). Btw, it
seems there should be some watchdog traces in logs around those
stalled pings.

Cheers,
Jarek P.
