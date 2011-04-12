From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: tc add mqprio qdisc support
Date: Tue, 12 Apr 2011 09:23:20 -0700
Message-ID: <20110412092320.05560b79@nehalam>
References: <20110412155727.4656.42756.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56003 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754859Ab1DLQXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 12:23:23 -0400
In-Reply-To: <20110412155727.4656.42756.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Apr 2011 08:57:27 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> Add mqprio qdisc support. Output matches the following,
> 
> # ./tc/tc qdisc
> qdisc mq 0: dev eth1 root
> qdisc mq 0: dev eth2 root
> qdisc mqprio 8001: dev eth3 root  tc 8 map 0 1 2 3 4 5 6 7 1 1 1 1 1 1 1 1
>              queues:(0:7) (8:15) (16:23) (24:31) (32:39) (40:47) (48:55) (56:63)
> 
> And usage is,
> 
> # ./tc/tc qdisc add dev eth3 root mqprio help
> Usage: ... mclass [num_tc NUMBER] [map P0 P1...]
>                   [offset txq0 txq1 ...] [count cnt0 cnt1 ...] [hw 1|0]
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied to net-next branch.



-- 
