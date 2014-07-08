From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iaf_packet: use BUG_ON
Date: Tue, 08 Jul 2014 16:22:04 -0700 (PDT)
Message-ID: <20140708.162204.1648218023530822781.davem@davemloft.net>
References: <20140708222023.GA11829@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140708222023.GA11829@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Wed, 9 Jul 2014 03:50:23 +0530

> Use BUG_ON(x) rather than if(x) BUG();
> 
> The semantic patch that fixes this problem is as follows:
> 
> // <smpl>
> @@ identifier x; @@
> -if (x) BUG();
> +BUG_ON(x);
> // </smpl>
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Please repost this with a proper subject line, correcting "iaf_packet".
