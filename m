From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Fri, 27 May 2011 10:27:30 +0100
Message-ID: <1306488451.2029.107.camel@i7.infradead.org>
References: <1301005107.2714.113.camel@edumazet-laptop>
	 <AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
	 <1301005946.2714.130.camel@edumazet-laptop>
	 <20110324.153623.45921344.davem@davemloft.net>
	 <1301006652.2714.145.camel@edumazet-laptop>
	 <AANLkTi=Xb3KCBKoVCcaVD5iyCtMCAnYaGF_DTeFQ0ays@mail.gmail.com>
	 <AANLkTinh9Li7DGgSqcZ+p9peS5XrHWomerSvKTYwHZ9-@mail.gmail.com>
	 <AANLkTi=hgOcwO8ojQBtmqbROS1qrhm5HCmq7tRxesc=6@mail.gmail.com>
	 <AANLkTinQq=BAVS1FrH80+VukTfAK1OKOkjEH4=gwZkv6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kyle Moffett <kyle@moffetthome.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alessandro Suardi <alessandro.suardi@gmail.com>,
	Hiroyuki Kawakatsu <hkawakat@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinQq=BAVS1FrH80+VukTfAK1OKOkjEH4=gwZkv6@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-03-25 at 02:25 +0100, Alessandro Suardi wrote:
> 
> ...which didn't take that long - one last bugging question and I'm happily
>  off to sleep; does ipid always come in the form of 0x followed by four
>  bytes representing hex values ? In a perhaps inelegant but working way
>  (I'm now writing through the VPN tunnel),
> 
>   sed 's/cache//;s/metric \?[0-9]\+ [0-9]\+//g;s/hoplimit
> [0-9]\+//g;s/ipid 0x....//g'
> 
>  appears to be Work For Me (TM).

Please could I have a tested patch for vpnc-script?

It now lives in its own repository at 
git://,	http://git.infradead.org/users/dwmw2/vpnc-scripts.git because
it's used by openconnect too, and has had various bug fixes for
cross-platform support and IPv6 since it was forked from vpnc.

-- 
dwmw2
