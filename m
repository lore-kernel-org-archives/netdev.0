From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: codel: fix build errors
Date: Mon, 14 May 2012 17:20:54 -0400 (EDT)
Message-ID: <20120514.172054.1808957948842230657.davem@davemloft.net>
References: <1337015687-17693-1-git-send-email-levinsasha928@gmail.com>
	<1337029683.8512.626.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: levinsasha928@gmail.com, edumazet@google.com,
	dave.taht@bufferbloat.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337029683.8512.626.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 May 2012 23:08:03 +0200

> Anonymous unions are fine, we use them a lot in kernel.
> 
> Please fix the initializers instead in fq_codel_dump_stats(), because
> these two #define are not very nice.

Agreed.
