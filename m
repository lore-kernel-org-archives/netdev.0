From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 11:56:41 -0800
Message-ID: <1425412601.5130.194.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425407104.17273.27.camel@perches.com>
	 <1425408125.5130.191.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425409671.17273.42.camel@perches.com>
	 <20150303.142758.822602589629075339.davem@davemloft.net>
	 <1425411669.17273.52.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425411669.17273.52.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 11:41 -0800, Joe Perches wrote:

> Until such time as the linux crosstools compilers are updated,
> (they seem stuck on 4.6.3 from 3 years ago)
> https://www.kernel.org/pub/tools/crosstool/
> I think the series is a trivial, small improvement.
> 
> I believe that's the only "argument" I've made.
> 
> Your choice to apply it or not, but if the series
> isn't appropriate, likely the existence of both
> eth_zero_addr and eth_broadcast_addr is suspect too.
> 

Please not that my objection was on patch 1/14 itself :

Using if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) in a slow path,
instead of leaving the existing memset() in place.

If people likes eth_broadcast_addr(), I have nothing against this.

Commit 6d57e9078e880a3dd232d579f42ac437a8f1ef7b
("etherdevice: introduce help function eth_zero_addr()")
was fine.
