From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 4/4] net_sched: add MQSAFE flag to qdisc
 to identify mq like qdiscs
Date: Mon, 20 Dec 2010 23:22:01 +0000
Message-ID: <1292887321.3055.43.camel@bwh-desktop>
References: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
	 <20101217153456.12170.17327.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, eric.dumazet@gmail.com,
	nhorman@tuxdriver.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10691 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758237Ab0LTXWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 18:22:05 -0500
In-Reply-To: <20101217153456.12170.17327.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-17 at 07:34 -0800, John Fastabend wrote:
> Add a MQSAFE flag to the qdisc schedulers that can be safely
> managed by sch_mclass. Without this flag schedulers that are
> not aware of multiple tx queues can be grafted under the
> mclass qdisc. Allowing incorrect qdiscs to be grafted causes
> an invalid mapping from qdisc's to netdevice queues.
[...]

This should be defined before adding sch_mclass, or at the same time,
not after.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

