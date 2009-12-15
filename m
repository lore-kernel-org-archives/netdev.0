From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth alignment fix for sh7724 using NET_IP_ALIGN
Date: Mon, 14 Dec 2009 23:15:34 -0800 (PST)
Message-ID: <20091214.231534.225225771.davem@davemloft.net>
References: <20091214103443.13082.84079.sendpatchset@rxone.opensource.se>
	<20091214.215753.147971281.davem@davemloft.net>
	<aec7e5c30912142313p111565d4mc0014c581cd431d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <aec7e5c30912142313p111565d4mc0014c581cd431d4@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>
Date: Tue, 15 Dec 2009 16:13:47 +0900

> Sorry about the confusion, but the #ifdef was actually intentional. =)
> I can't find any description of the RPADIR register in the sh7724 data
> sheet, but testing shows that the buffers are adjusted properly. So
> since I don't know the register layout I prefer to optimize for the
> known working combination of NET_IP_ALIGN == 2 and simply disable
> .rpadir usage for other NET_IP_ALIGN cases.

NET_IP_ALIGN is never != 2 on SUPERH

SH_ETH depends on SUPERH

It's a fantasy ifdef, of sorts. :-)

