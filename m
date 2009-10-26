From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] [PATCH] udp: Don't save dst in udpv6_sendmsg()
Date: Mon, 26 Oct 2009 09:45:26 -0700
Message-ID: <4AE5D226.3020307@hp.com>
References: <20091023111336.4733.4901.sendpatchset@localhost.localdomain> <20091024.064010.145864194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:23259 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486AbZJZQpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 12:45:25 -0400
In-Reply-To: <20091024.064010.145864194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> Date: Fri, 23 Oct 2009 16:43:36 +0530
> 
> 
>>Performance: I ran netperf UDPv6 RR to use connected sockets.
>>Tested with a 70 min run, aggregate of 5 netperf runs for
>>each result.
> 
> 
> Who actually uses connected UDP sockets? :-)

Somebody must, they sent me patches to optionally connect() the endpoints in a 
UDP_RR test :)

rick jones

trying to decide if he should by default set SO_DONTROUTE on UDP sockets to 
cover the backsides of testers who cause link-down events on devices under test 
with systems connected to their employer's site lans with the default route 
pointing at same...
