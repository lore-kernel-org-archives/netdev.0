From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Mon, 02 Nov 2015 07:24:57 -0800
Message-ID: <1446477897.23275.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-02 at 16:11 +0200, Denys Fedoryshchenko wrote:
> Hi!
> 
> Actually seems i was getting this panic for a while (once per week) on 
> loaded pppoe server, but just now was able to get full panic message.
> After checking commit logs on sch_fq.c i didnt seen any fixes, so 
> probably upgrading to newer kernel wont help?

I do not think we support sch_fq as a HTB leaf.

If you want both HTB and sch_fq, you need to setup a bonding device.

HTB on bond0

sch_fq on the slaves

Sure, the kernel should not crash, but HTB+sch_fq on same net device is
certainly not something that will work anyway.
