From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Add low latency socket busy_poll support
Date: Wed, 4 Feb 2015 12:24:37 +0600
Message-ID: <20150204062436.GE30631@kumar-pc.asicdesigners.com>
References: <1422940816-27402-1-git-send-email-hariprasad@chelsio.com>
 <54D0FB41.1030802@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hariprasad Shenai <hariprasad@chelsio.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<leedom@chelsio.com>, <anish@chelsio.com>, <nirranjan@chelsio.com>,
	<praveenm@chelsio.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24300 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbbBDGyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:54:45 -0500
Content-Disposition: inline
In-Reply-To: <54D0FB41.1030802@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick,

On Tuesday, February 02/03/15, 2015 at 08:45:53 -0800, Rick Jones wrote:
> On 02/02/2015 09:20 PM, Hariprasad Shenai wrote:
> >cxgb_busy_poll, corresponding to ndo_busy_poll, gets called by the socket
> >waiting for data.
> >
> >With busy_poll enabled, improvement is seen in latency numbers as observed by
> >collecting netperf TCP_RR numbers.
> 
> Which, not surprisingly, leads to the question - how much
> improvement? :)  Extra credit for including the change in
> netperf-reported service demands.
> 
> happy benchmarking,
> 
> rick jones
> 

netperf was not changed in this case. Rather, busy-polling was enabled globally by
setting sysctls busy_poll and busy_read.

We will post the improvement numbers when submitting V2.


Thanks,
Kumar.
