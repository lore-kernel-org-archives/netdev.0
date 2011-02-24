From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 24 Feb 2011 16:07:48 +0800
Message-ID: <AANLkTikE_OU_qiBUdiDP39js8jQzGqqo1FYW2uHmw3He@mail.gmail.com>
References: <AANLkTikgDsM15DO7u2SP15xx=Y_pg6JdCLrie8ACobJP@mail.gmail.com>
 <20110131.203556.193730771.davem@davemloft.net> <AANLkTimorcNAEbSpuE_dUXKuOBZDcDcGSJ2cGefniThc@mail.gmail.com>
 <20110223.235129.02262510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mirqus@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, joe@perches.com, dilinger@queued.net,
	ratbert@faraday-tech.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110223.235129.02262510.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Thu, Feb 24, 2011 at 3:51 PM, David Miller <davem@davemloft.net> wrote:
> From: Po-Yu Chuang <ratbert.chuang@gmail.com>
> Date: Thu, 24 Feb 2011 15:27:55 +0800
>
>> I guess the problem is because a HW restriction that the rx buffer must be
>> 64 bits aligned. Since I cannot make rx buffer starts at offset 2 bytes, the
>> IP header, TCP header and data are not 4 bytes aligned. The performance
>> drops drastically.
>
> I cannot believe that after 20 years of commodity ethernet networking
> chips were first designed, people are still designing hardware that
> doesn't do this right.

Ha ha...
Well, this restriction was removed in the later IPs of our company. :-p

>
> Just emit garbage bytes into the sub-word alignment padding if the chip
> wants to word align it's DMA writes.

Not sure what do you mean. The problem is that HW does not accept a
base address of RX buffer which is not 8 bytes aligned.

> Even the 15 year old Dec Tulip chips do this properly.

best regards,
Po-Yu Chuang
