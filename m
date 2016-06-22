From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cavium: liquidio: Use vzalloc instead of vmalloc
Date: Wed, 22 Jun 2016 16:20:13 -0400 (EDT)
Message-ID: <20160622.162013.1679523707328434467.davem@davemloft.net>
References: <20160618065320.GA1906@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160618065320.GA1906@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Sat, 18 Jun 2016 12:23:20 +0530

> vzalloc combines vmalloc and memset 0.
> 
> The Coccinelle semantic patch used to make this change is as follows:
> @@
> type T;
> T *d;
> expression e;
> statement S;
> @@
> 
>         d =
> -            vmalloc
> +            vzalloc
>              (...);
>         if (!d) S
> -       memset(d, 0, sizeof(T));
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

This dos not apply cleanly to net-next.
