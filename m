From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/macvtap: fix error check
Date: Mon, 07 Mar 2011 15:58:32 -0800 (PST)
Message-ID: <20110307.155832.52202423.davem@davemloft.net>
References: <20110305004941.7b195e9d@absol.kitzblitz>
	<201103071059.04321.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikai@nikai.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103071059.04321.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 7 Mar 2011 10:59:04 +0100

> On Saturday 05 March 2011, Nicolas Kaiser wrote:
>> 'len' is unsigned of type size_t and can't be negative.
>> 
>> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> 
> I think it's harmless: the worst thing that can happen is
> macvtap_alloc_skb() failing with ENOMEM when it gets a
> large argument, but we could have it in -stable just to
> be sure.

I'm just going to add it to net-2.6

I verified that gcc is not generating this test at all
currently, so putting this into -stable is quite pointless.
