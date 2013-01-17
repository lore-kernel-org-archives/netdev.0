From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: fix GRO parameters
Date: Thu, 17 Jan 2013 09:16:09 +0200
Message-ID: <50F7A539.7050508@broadcom.com>
References: <50F50537.3030608@broadcom.com>
 <1358260752.8744.5677.camel@edumazet-glaptop>
 <50F56178.8000502@broadcom.com>
 <20130115.150914.729025796621947521.davem@davemloft.net>
 <1358312188.19956.1.camel@edumazet-glaptop>
 <1358314662.19956.51.camel@edumazet-glaptop>
 <50F65060.5000901@broadcom.com>
 <1358350146.19956.658.camel@edumazet-glaptop>
 <50F6BB70.8070409@broadcom.com>
 <1358355038.19956.694.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Eilon Greenstein" <eilong@broadcom.com>, ariele@broadc_tym.com
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1483 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759203Ab3AQIOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 03:14:51 -0500
In-Reply-To: <1358355038.19956.694.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is no downside providing gso_segs and gso_type, you have all
> needed information as shown in the patch I cooked and tested.
> 
> Our goal is to remove CONFIG_INET_LRO, so all multi-segments packets
> should have the same set of parameters (gso_size, gso_segs, gso_type)

I concur - I'll make the semantic modification to your patch and re-submit
it later on today.

Thanks,
Yuval
