From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Mon, 02 Apr 2012 19:29:56 -0700
Message-ID: <4F7A60A4.5040600@hp.com>
References: <1333417997.18626.1.camel@edumazet-glaptop> <20120402.215911.1929019308299701014.davem@davemloft.net> <1333419304.18626.5.camel@edumazet-glaptop> <20120402.222300.1137842205135530387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, remi@remlab.net, levinsasha928@gmail.com,
	remi.denis-courmont@nokia.com, davej@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:19243 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370Ab2DCC37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 22:29:59 -0400
In-Reply-To: <20120402.222300.1137842205135530387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2012 07:23 PM, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Tue, 03 Apr 2012 04:15:04 +0200
>
>> Any idea of a representative benchmark in dgram af_unix ?
>
> Maybe you could try to make bw_unix from lmbench use
> SOCK_DGRAM? :-)

I don't know it isn't entirely bitrotted, but there are streaming and 
datagram AF_UNIX tests in netperf - they require conditional inclusion 
via ./configure --enable-unixdomain:

http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#DG_005fSTREAM

happy benchmarking,

rick jones
