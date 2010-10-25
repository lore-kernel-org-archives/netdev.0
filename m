From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add __rcu annotation to sk_filter
Date: Mon, 25 Oct 2010 14:19:47 -0700 (PDT)
Message-ID: <20101025.141947.200381218.davem@davemloft.net>
References: <1288014425.2826.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48811
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756545Ab0JYVTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 17:19:24 -0400
In-Reply-To: <1288014425.2826.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 15:47:05 +0200

> Add __rcu annotation to :
>         (struct sock)->sk_filter
> 
> And use appropriate rcu primitives to reduce sparse warnings if
> CONFIG_SPARSE_RCU_POINTER=y
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
