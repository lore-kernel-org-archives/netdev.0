From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 39/57] net: irq: Remove IRQF_DISABLED
Date: Wed, 21 Sep 2011 13:40:26 -0400 (EDT)
Message-ID: <20110921.134026.121607758721728538.davem@davemloft.net>
References: <1316597339-29861-1-git-send-email-yong.zhang0@gmail.com>
	<1316597339-29861-40-git-send-email-yong.zhang0@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, perex@perex.cz, leitao@linux.vnet.ibm.com,
	olof@lixom.net, nico@fluxnic.net, steve.glendinning@smsc.com,
	geoff@infradead.org, t.sailer@alumni.ethz.ch, jreuter@yaina.de,
	klaus.kudielka@ieee.org, jpr@f6fbb.org, samuel@sortiz.org,
	chunkeey@googlemail.com, linville@tuxdriver.com,
	jeffrey.t.kirsher@intel.com, jpirko@redhat.com, bob.liu@analog.com,
	grundler@parisc-linux.org, ralf@linux-mips.org, blogic@openwrt.org,
	marc@tensilica.com, lucas.demarchi@profusion.mobi, joe@perches.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	cbe-oss-dev@lists.ozlabs.org, linux-hams@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: yong.zhang0@gmail.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1316597339-29861-40-git-send-email-yong.zhang0@gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yong Zhang <yong.zhang0@gmail.com>
Date: Wed, 21 Sep 2011 17:28:40 +0800

> Since commit [c58543c8: genirq: Run irq handlers with interrupts disabled],
> We run all interrupt handlers with interrupts disabled
> and we even check and yell when an interrupt handler
> returns with interrupts enabled (see commit [b738a50a:
> genirq: Warn when handler enables interrupts]).
> 
> So now this flag is a NOOP and can be removed.
> 
> Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>

Acked-by: David S. Miller <davem@davemloft.net>
