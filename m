From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH RESEND net-next 1/7] bonding: use ether_addr_equal_unaligned
 for bond addr compare
Date: Thu, 2 Jan 2014 08:39:29 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1401020839000.2182@localhost6.localdomain6>
References: <52C4BD16.5010702@huawei.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C4BD16.5010702@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -// compare MAC addresses
> -#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
> +/* compare MAC addresses */
> +#define MAC_ADDRESS_EQUAL(A, B)	\
> +	ether_addr_equal_64bits((const u8 *)A, (const u8 *)B)

Are the casts needed?

julia
