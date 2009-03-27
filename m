From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] mlx4_en: Separating default QP in RSS context
Date: Fri, 27 Mar 2009 00:35:44 -0700 (PDT)
Message-ID: <20090327.003544.79654528.davem@davemloft.net>
References: <49CB87EB.8060404@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbZC0Hf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:35:57 -0400
In-Reply-To: <49CB87EB.8060404@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 26 Mar 2009 15:49:31 +0200

> The default QP number in RSS is no longer part of the RSS table.
> We want to separate TCP streams from other streams because we
> want to handle them differently. Changed the RSS mask to perform
> the hashing on TCP packets only and to send all the others to the
> default ring.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

I disagree with this change.  I understand why you are doing
it, to implement your frag'd vs. non-frag'd skb patch coming
up.

But that doesn't make it any more right.

UDP and IPSEC traffic should be multiqueue balanced just like any
other traffic.

I'm not applying this patch set, sorry.

I'd also like to ask you to convert your driver over to GRO
instead of LRO which we are trying to deprecate.

