From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pkt_sched: gen_estimator: Optimize
 gen_estimator_active()
Date: Wed, 26 Nov 2008 08:29:22 -0800
Message-ID: <20081126082922.55317adf@extreme>
References: <20081125102113.371db7b1@extreme>
	<20081126111021.GA12337@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43167 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752266AbYKZQ3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 11:29:35 -0500
In-Reply-To: <20081126111021.GA12337@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Nov 2008 11:10:22 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

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

yeah sure, i just coded the obvious way.
