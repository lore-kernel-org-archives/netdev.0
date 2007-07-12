From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 14:27:05 -0700
Message-ID: <46969CA9.8030406@hp.com>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>	<20070712.023710.36923635.davem@davemloft.net>	<20070712.225950.12335719.noboru.obata.ar@hitachi.com>	<20070712.132448.115910193.davem@davemloft.net> <20070712141203.7350429a@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: noboru.obata.ar@hitachi.com, David Miller <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:34337 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755607AbXGLV3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 17:29:31 -0400
In-Reply-To: <20070712141203.7350429a@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> One question is why the RTO gets so large that it limits failover?
> 
> If Linux TCP is working correctly,  RTO should be srtt + 2*rttvar
> 
> So either there is a huge srtt or variance, or something is going
> wrong with RTT estimation.  Given some reasonable maximums of
> Srtt = 500ms and rttvar = 250ms, that would cause RTO to be 1second.

I suspect that what is happening here is that a link goes down in a 
trunk somewhere for some number of seconds, resulting in a given TCP 
segment being retransmitted several times, with the doubling of the RTO 
each time.

rick jones
