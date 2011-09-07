From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 45/62] net: irq: Remove IRQF_DISABLED
Date: Wed, 07 Sep 2011 13:13:25 -0400 (EDT)
Message-ID: <20110907.131325.897937687962213943.davem@davemloft.net>
References: <1315383059-3673-1-git-send-email-yong.zhang0@gmail.com>
	<1315383059-3673-46-git-send-email-yong.zhang0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: perex@perex.cz, dhowells@redhat.com, prakity@marvell.com,
	netdev@vger.kernel.org, chunkeey@googlemail.com,
	sonic.zhang@analog.com, klaus.kudielka@ieee.org,
	t.sailer@alumni.ethz.ch, khilman@ti.com, eric.dumazet@gmail.com,
	jhovold@gmail.com, cyril@ti.com, rmk+kernel@arm.linux.org.uk,
	mingo@elte.hu, jpr@f6fbb.org, adobriyan@gmail.com,
	jreuter@yaina.de, cbe-oss-dev@lists.ozlabs.org,
	martinez.javier@gmail.com, samuel@sortiz.org, vapier@gentoo.org,
	grundler@parisc-linux.org, tklauser@distanz.ch,
	lucas.demarchi@profusion.mobi, u.kleine-koenig@pengutronix.de,
	olof@lixom.net, uclinux-dist-devel@blackfin.uclinux.org,
	linux-hams@vger.kernel.org, tglx@linutronix.de,
	leitao@linux.vnet.ibm.com, blogic@openwrt.org,
	shawn.guo@linaro.org, nico@fluxnic.net, geoff@infradead.org,
	jkosina@suse.cz, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	ralph.hem
To: yong.zhang0@gmail.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1315383059-3673-46-git-send-email-yong.zhang0@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: Yong Zhang <yong.zhang0@gmail.com>
Date: Wed,  7 Sep 2011 16:10:42 +0800

> This flag is a NOOP and can be removed now.
> 
> Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>

I have the same concerns here as I had for the sparc case.

Some of these drivers might be using IRQF_DISABLED to make sure the
IRQ cannot be delivered until it is explicitly enabled via an
enable_irq() call.

How is that being accomodated now?
