From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [klibc] [patch] import socket defines
Date: Thu, 10 Jan 2008 23:10:07 -0800
Message-ID: <4787164F.9030805@zytor.com>
References: <477BD374.6060506@zytor.com> <200801110123.38406.vapier@gentoo.org> <20080110.224749.66236050.davem@davemloft.net> <200801110207.39736.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klibc@zytor.com
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:55497 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbYAKHOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 02:14:52 -0500
In-Reply-To: <200801110207.39736.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Frysinger wrote:
> oh, sorry, i see what you mean.  i was thinking in terms of crap removed (as 
> that's what i'm after), not crap added (which is what Peter is after).  i 
> hadnt noticed that.  i dont know if it'll break glibc (and really, any other 
> sane libc).  if that is the case, then i think klibc here is the 2nd class 
> citizen to everyone else.

I don't really understand why you insist on using such inflammatory 
language; all this stuff is ABI constants, and the only reason glibc 
doesn't use them is that glibc prefers to use enums over #defines.

Right now, glibc is special-cased.  glibc also tends to be very 
deliberate about its kernel header inclusions.  It wants a subset of the 
available defines, so it can include a subset header.

The reverse is definitely possible too -- all other users (kernel, 
newlib, dietlibc, uclibc, and klibc) can change and leave the current 
state for glibc.

We can special-case the kernel in the above case, but that would involve 
some additional ugliness.

	-hpa
