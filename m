From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] SMC911X: Fix using of dereferenced skb after netif_rx
Date: Mon, 03 Dec 2007 14:47:16 +0100
Message-ID: <87wsrvyjob.fsf@macbook.be.48ers.dk>
References: <4753B74D.4070505@cn.fujitsu.com>
	<20071203101141.GA23549@gondor.apana.org.au>
	<4753D7F3.3050201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Dustin McIntire <dustin@sensoria.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:4794 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271AbXLCNrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 08:47:35 -0500
Received: by ug-out-1314.google.com with SMTP id z38so2317028ugc
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2007 05:47:34 -0800 (PST)
In-Reply-To: <4753D7F3.3050201@cn.fujitsu.com> (Wang Chen's message of "Mon\, 03 Dec 2007 18\:18\:27 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wang" == Wang Chen <wangchen@cn.fujitsu.com> writes:

Hi,

 Wang> +	len = skb->len;
 Wang>  	netif_rx(skb);
 dev-> stats.rx_packets++;
 Wang> -	dev->stats.rx_bytes += skb->len;
 Wang> +	dev->stats.rx_bytes += len;

Why not simply update the stats before calling netif_rx as the return
value isn't checked anyway?

-- 
Bye, Peter Korsgaard
