From: Brian Haley <brian.haley@hp.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Tue, 01 Oct 2013 14:57:33 -0400
Message-ID: <524B1B1D.3050304@hp.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Wolfgang Walter <linux@stwm.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:34783 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab3JAS5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 14:57:36 -0400
In-Reply-To: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2013 12:39 PM, Wolfgang Walter wrote:
> Hello,
> 
> I tried to upgrade one of our routers to 3.10.13 from 3.4.63 and I see a 
> dramatic performance loss. I tried 3.11.2 and it is still there.
> 
> *** Symptoms:
> 
> All network traffic over the router become slow and sluggish. If one pings the 
> router there is a packet loss. After about 2 minutes the traffic completely 
> stalls for about 1 minute. Then it works again as in the beginning to then 
> stall again. And so on.
> 
> This happens even with rather moderate traffic. While still routing the CPU 
> utilization is higher than it is with 3.4.63 but only moderately.
> 
> When it stalls no network traffic seems possible (but to loopback). If one 
> tries to ping from the router any target (even if it is on a interface with no 
> traffic at all) one gets:
> 
> 	ping: sendmsg: No buffer space available

dmesg show anything?  I've seen this happen when the neighbour table is full,
but that's not a typical occurence.

-Brian
