From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] ipv6: fix the reassembly expire code in
 nf_conntrack
Date: Mon, 17 Sep 2012 22:35:59 -0400 (EDT)
Message-ID: <20120917.223559.1226100441781312938.davem@davemloft.net>
References: <20120917.125419.1478223385564528540.davem@davemloft.net>
	<20120917.125925.930848734158369358.davem@davemloft.net>
	<1347935656.14402.12.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: amwang@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347935656.14402.12.camel@cr0>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Tue, 18 Sep 2012 10:34:16 +0800

> Actually, the #ifdef CONFIG_IPV6 is not needed at all, as
> sockstat6_seq_show() is their only caller, which is compiled only when
> CONFIG_IPV6 is enabled.

"#ifdef CONFIG_IPV6 doesn't work for modular ipv6.
