From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 16:42:40 +0800
Message-ID: <49ED8700.3010603@cn.fujitsu.com>
References: <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <49ED406F.2040401@cn.fujitsu.com> <49ED4407.8010200@cosmosbay.com> <49ED5813.1000803@cn.fujitsu.com> <20090420224540.30d7b0ed@nehalam> <49ED6D2E.5060808@cn.fujitsu.com> <20090421081649.GA16782@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090421081649.GA16782@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> 
> Netfilter as long as other generic network pathes are never accessed
> from interrupt context, but your analysis looks right for the softirq
> case.
> 

A question:

softirq is always not nesting. Why we need recursive lock?

Lai.

