From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 24 Feb 2011 10:43:13 -0800 (PST)
Message-ID: <20110224.104313.68122155.davem@davemloft.net>
References: <AANLkTimorcNAEbSpuE_dUXKuOBZDcDcGSJ2cGefniThc@mail.gmail.com>
	<20110223.235129.02262510.davem@davemloft.net>
	<AANLkTikE_OU_qiBUdiDP39js8jQzGqqo1FYW2uHmw3He@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, joe@perches.com, dilinger@queued.net,
	ratbert@faraday-tech.com
To: ratbert.chuang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikE_OU_qiBUdiDP39js8jQzGqqo1FYW2uHmw3He@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Date: Thu, 24 Feb 2011 16:07:48 +0800

> On Thu, Feb 24, 2011 at 3:51 PM, David Miller <davem@davemloft.net> wrote:
>> Just emit garbage bytes into the sub-word alignment padding if the chip
>> wants to word align it's DMA writes.
> 
> Not sure what do you mean. The problem is that HW does not accept a
> base address of RX buffer which is not 8 bytes aligned.

I am saying this is what hardware should do if it has such a
restriction.
