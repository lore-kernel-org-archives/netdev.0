From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/2] pkt_sched: Rename PSCHED_US2NS and PSCHED_NS2US
Date: Mon, 15 Jun 2009 02:32:11 -0700 (PDT)
Message-ID: <20090615.023211.236994052.davem@davemloft.net>
References: <20090609080513.GB5237@ff.dom.local>
	<20090615091523.GA10411@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, vexwek@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, devik@cdi.cz, dada1@cosmosbay.com,
	hazard@francoudi.com, slavon@bigtelecom.ru
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59919
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752945AbZFOJcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 05:32:08 -0400
In-Reply-To: <20090615091523.GA10411@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 15 Jun 2009 09:15:23 +0000

> On Tue, Jun 09, 2009 at 08:05:13AM +0000, Jarek Poplawski wrote:
> ...
>> This change breaks ticks - microseconds similarity, so some minor code
>> fixes might be needed. It is also planned to change naming adequately
>> eg. to PSCHED_TICKS2NS() etc. in the near future.
> 
> -------------------->
> pkt_sched: Rename PSCHED_US2NS and PSCHED_NS2US
> 
> Let's use TICKS instead of US, so PSCHED_TICKS2NS and PSCHED_NS2TICKS
> (like in PSCHED_TICKS_PER_SEC already) to avoid misleading.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Also applied to net-next-2.6, thanks.
