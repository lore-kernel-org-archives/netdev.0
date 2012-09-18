From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next 0/4] ipv6: fix the reassembly expire code in
 nf_conntrack
Date: Tue, 18 Sep 2012 10:47:23 +0800
Message-ID: <1347936443.14402.15.camel@cr0>
References: <20120917.125419.1478223385564528540.davem@davemloft.net>
	 <20120917.125925.930848734158369358.davem@davemloft.net>
	 <1347935656.14402.12.camel@cr0>
	 <20120917.223559.1226100441781312938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120917.223559.1226100441781312938.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-09-17 at 22:35 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue, 18 Sep 2012 10:34:16 +0800
> 
> > Actually, the #ifdef CONFIG_IPV6 is not needed at all, as
> > sockstat6_seq_show() is their only caller, which is compiled only when
> > CONFIG_IPV6 is enabled.
> 
> "#ifdef CONFIG_IPV6 doesn't work for modular ipv6.

Ah... then this should be the cause of your build failure, as I always
compile IPV6 as builtin.

Sorry for this, my bad. I will remove this #ifdef and resend the whole
patchset.

Thanks!

