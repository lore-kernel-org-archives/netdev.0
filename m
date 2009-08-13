From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 16:24:20 -0400
Message-ID: <4A847674.5030508@hp.com>
References: <1250091560.6641.48.camel@fnki-nb00130>	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>	 <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home>	 <48AAB7CB-8EEC-4E30-B821-3E0D84531AAA@oracle.com>	 <1250187662.28285.97.camel@Joe-Laptop.home>	 <5D6A7C11-B300-4E39-BBDF-EF18C4BAE419@oracle.com> <1250190346.28285.120.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:8603 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089AbZHMUYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 16:24:21 -0400
In-Reply-To: <1250190346.28285.120.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> I suppose ipv6_addr_v4mapped(addr) could be tested instead
> 
> Perhaps this on top of last:
> 
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index dd02842..7ce34a7 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -25,6 +25,7 @@
>  #include <linux/kallsyms.h>
>  #include <linux/uaccess.h>
>  #include <linux/ioport.h>
> +#include <net/ipv6.h>

I was trying to avoid this by open-coding the v4mapped check, didn't
know if IPv6-specific headers should be pulled-into this generic
code, even though we're printing IPv6 addresses.

-Brian
