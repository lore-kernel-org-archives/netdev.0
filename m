From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Max number of TCP sessions
Date: Thu, 16 Nov 2006 14:52:08 -0800
Message-ID: <1163717529.26263.1.camel@raj-laptop>
References: <455CC8C9.2050509@superbug.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:25517 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1754889AbWKPWwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 17:52:10 -0500
To: James Courtier-Dutton <James@superbug.co.uk>
In-Reply-To: <455CC8C9.2050509@superbug.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-16 at 20:23 +0000, James Courtier-Dutton wrote: 
> Hi,
> 
> For a host using a Pentium 4 CPU at 2.8Mhz, what is a sensible max value 
> for number of TCP sessions this host could run under Linux?
> Bandwidth per TCP session is likely to be about 10kbytes/second.

To a first order, and assuming that there is nearly no user-space
processing for those TCP connections (TCP is a transport not a session
protocol :) you could take a netperf TCP_RR test result - using the
service demand - usec of CPU/KB transferred you could then do some back
of the envelope calculations as to the number of 10 KByte/s connections
you could support.  It would be a bit of handwaving, but give yourself
say a 20% pad and you'll probably be OK.

rick jones

> 
> Kind Regards
> 
> James
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

