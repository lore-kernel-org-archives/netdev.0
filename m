From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for May 12 (netfilter: xt_TEE)
Date: Wed, 12 May 2010 14:53:39 -0700 (PDT)
Message-ID: <20100512.145339.00461355.davem@davemloft.net>
References: <20100512085045.483f0e2d.randy.dunlap@oracle.com>
	<alpine.LSU.2.01.1005122210180.11190@obet.zrqbmnf.qr>
	<20100512131942.f487b3a9.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, kaber@trash.net, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	sebastian.classen@freenet.ag
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100512131942.f487b3a9.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 12 May 2010 13:19:42 -0700

> On Wed, 12 May 2010 22:11:35 +0200 (CEST) Jan Engelhardt wrote:
> 
>> parent cba7a98a474a4f2a9316473734ba76829191a78a (v2.6.34-rc5-1489-gcba7a98)
>> commit cff884ea0de4bf8729ac33bb5d98ac9d39d09019
>> Author: Jan Engelhardt <jengelh@medozas.de>
>> Date:   Wed May 12 22:10:03 2010 +0200
>> 
>> netfilter: xtables: add missing depends for xt_TEE
>> 
>> Aviod these link-time errors when IPV6=m, XT_TEE=y:
>> 
>> net/built-in.o: In function `tee_tg_route6':
>> xt_TEE.c:(.text+0x45ca5): undefined reference to `ip6_route_output'
>> net/built-in.o: In function `tee_tg6':
>> xt_TEE.c:(.text+0x45d79): undefined reference to `ip6_local_out'
>> 
>> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
 ...
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

I'll apply this directly, thanks everyone.
