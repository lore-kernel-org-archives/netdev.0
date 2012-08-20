From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xfrm: fix RCU bugs
Date: Mon, 20 Aug 2012 09:14:28 +0200
Message-ID: <1345446868.5158.246.camel@edumazet-glaptop>
References: <1345372308.5158.54.camel@edumazet-glaptop>
	 <5031BFB1.200@windriver.com> <1345440800.5158.239.camel@edumazet-glaptop>
	 <5031DA57.1000904@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, fengguang.wu@intel.com,
	Priyanka Jain <Priyanka.Jain@freescale.com>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40281 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755292Ab2HTHOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 03:14:33 -0400
Received: by weyx8 with SMTP id x8so3709427wey.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 00:14:31 -0700 (PDT)
In-Reply-To: <5031DA57.1000904@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 14:33 +0800, Fan Du wrote:

> And one out of topic question:
> The usage of xfrm_state_afinfo_lock/xfrm_km_lock is extremely
> similar with xfrm_policy_afinfo_lock, except the former is not so
> frequently read than that of the later.
> 
> Is it justified to convert RW xfrm_state_afinfo_lock/xfrm_km_lock into
> RCU?
> 

I would say it is justified, and easy enough.
