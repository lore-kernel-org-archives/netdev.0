From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 v2] epic100: hamachi: yellowfin: Fix skb
 allocation size
Date: Sat, 25 Dec 2010 19:42:20 -0800 (PST)
Message-ID: <20101225.194220.189701956.davem@davemloft.net>
References: <4D15F6C9.50700@scarlet.be>
	<20101225151217.GA1994@del.dom.local>
	<20101225173959.GB2264@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soete.joel@scarlet.be, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101225173959.GB2264@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 25 Dec 2010 18:39:59 +0100

> Joel Soete reported oopses during pppoe over sundance NIC, caused by
> a bug in skb allocation and dma mapping code, where skb_reserve()
> bytes weren't taken into account. As a followup to the patch:
> "sundance: Fix oopses with corrupted skb_shared_info" very similar
> code is fixed here for three other drivers.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Also applied, thanks.
