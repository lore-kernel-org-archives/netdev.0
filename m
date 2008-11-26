From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: gen_estimator: Optimize
 gen_estimator_active()
Date: Wed, 26 Nov 2008 15:24:42 -0800 (PST)
Message-ID: <20081126.152442.139201565.davem@davemloft.net>
References: <20081125102113.371db7b1@extreme>
	<20081126111021.GA12337@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55604
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752076AbYKZXYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:24:43 -0500
In-Reply-To: <20081126111021.GA12337@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 26 Nov 2008 11:10:22 +0000

> pkt_sched: gen_estimator: Optimize gen_estimator_active()
> 
> Since all other gen_estimator functions use bstats and rate_est params
> together, and searching for them is optimized now, let's use this also
> in gen_estimator_active(). The return type of gen_estimator_active()
> is changed to bool, and gen_find_node() parameters to const, btw.
> 
> In tcf_act_police_locate() a check for ACT_P_CREATED is added before
> calling gen_estimator_active().
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
