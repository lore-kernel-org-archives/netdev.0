From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8]: net: rps: reset network header before calling
 skb_get_rxhash()
Date: Thu, 19 Aug 2010 17:08:51 -0700 (PDT)
Message-ID: <20100819.170851.258130071.davem@davemloft.net>
References: <1282107656-3386-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751194Ab0HTAIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 20:08:35 -0400
In-Reply-To: <1282107656-3386-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 18 Aug 2010 13:00:56 +0800

> skb_get_rxhash() assumes the network header pointer of the skb is set
> properly after the commit: 
> 
> commit bfb564e7391340638afe4ad67744a8f3858e7566
> Author: Krishna Kumar <krkumar2@in.ibm.com>
> Date:   Wed Aug 4 06:15:52 2010 +0000
> 
>     core: Factor out flow calculation from get_rps_cpu
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
