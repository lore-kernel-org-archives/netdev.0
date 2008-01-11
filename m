From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [klibc] [patch] import socket defines
Date: Thu, 10 Jan 2008 23:42:28 -0800
Message-ID: <47871DE4.40906@zytor.com>
References: <477BD374.6060506@zytor.com> <200801110123.38406.vapier@gentoo.org> <20080110.224749.66236050.davem@davemloft.net> <200801110207.39736.vapier@gentoo.org> <4787164F.9030805@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klibc@zytor.com
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:44544 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbYAKHx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 02:53:29 -0500
In-Reply-To: <4787164F.9030805@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

H. Peter Anvin wrote:
> 
> Right now, glibc is special-cased.  glibc also tends to be very 
> deliberate about its kernel header inclusions.  It wants a subset of the 
> available defines, so it can include a subset header.
> 
> The reverse is definitely possible too -- all other users (kernel, 
> newlib, dietlibc, uclibc, and klibc) can change and leave the current 
> state for glibc.
> 
> We can special-case the kernel in the above case, but that would involve 
> some additional ugliness.
> 

Just to clarify: I don't have any strong opinions for any particular 
option -- I'm fine with either.  I'd just like to get rid of the 
ugliness of having #defines for any particular user spaces, and I'd 
prefer two include files over feature test macros.

	-hpa
