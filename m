From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] cxgb4: Add low latency socket busy_poll support
Date: Tue, 03 Feb 2015 08:45:53 -0800
Message-ID: <54D0FB41.1030802@hp.com>
References: <1422940816-27402-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com, kumaras@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:37626 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754570AbbBCQpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 11:45:55 -0500
In-Reply-To: <1422940816-27402-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2015 09:20 PM, Hariprasad Shenai wrote:
> cxgb_busy_poll, corresponding to ndo_busy_poll, gets called by the socket
> waiting for data.
>
> With busy_poll enabled, improvement is seen in latency numbers as observed by
> collecting netperf TCP_RR numbers.

Which, not surprisingly, leads to the question - how much improvement? 
:)  Extra credit for including the change in netperf-reported service 
demands.

happy benchmarking,

rick jones
