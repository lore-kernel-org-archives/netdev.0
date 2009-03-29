From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH 2/6] mlx4_en: Separating default QP in RSS context
Date: Sun, 29 Mar 2009 13:10:57 +0300
Message-ID: <49CF4931.90207@mellanox.co.il>
References: <49CB87EB.8060404@mellanox.co.il> <20090327.003544.79654528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39576 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752826AbZC2KMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2009 06:12:07 -0400
In-Reply-To: <20090327.003544.79654528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> 
> I disagree with this change.  I understand why you are doing
> it, to implement your frag'd vs. non-frag'd skb patch coming
> up.
> 
> But that doesn't make it any more right.
> 
> UDP and IPSEC traffic should be multiqueue balanced just like any
> other traffic.
> 
> I'm not applying this patch set, sorry.
> 

I understand, but patches 1,5,6 have nothing to do with this change
and touch completely other parts of the driver.

Thanks,
Yevgeny

