From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Thu, 16 Jun 2016 11:10:23 -0700
Message-ID: <5762EB8F.60801@hpe.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:51162 "EHLO
	g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992AbcFPSK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 14:10:27 -0400
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com [15.233.44.27])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 132FF62CEC
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 18:10:26 +0000 (UTC)
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2016 10:51 AM, Tom Herbert wrote:

> Note that #1 is really about running a transport stack in userspace
> applications in clients, not necessarily servers. For servers we
> intend to modified the kernel stack in order to leverage existing
> implementation for building scalable serves (hence these patches).

Only if there is a v2 for other reasons...  I assume that was meant to 
be "scalable servers."


> Tested: Various cases of TOU with IPv4, IPv6 using TCP_STREAM and
> TCP_RR. Also, tested IPIP for comparing TOU encapsulation to IP
> tunneling.
>
>      - IPv6 native
>        1 TCP_STREAM
> 	8394 tps

TPS for TCP_STREAM?  Is that Mbit/s?

>        200 TCP_RR
> 	1726825 tps
> 	100/177/361 90/95/99% latencies

To enhance the already good comprehensiveness of the numbers, a 1 TCP_RR 
showing the effect on latency rather than aggregate PPS would be 
goodness, as would a comparison of the service demands of the different 
single-stream results.

CPU and NIC models would provide excellent context for the numbers.

happy benchmarking,

rick jones
