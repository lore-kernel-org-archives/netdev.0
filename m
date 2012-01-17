From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 1/4] CS89x0 : add platform driver support
Date: Tue, 17 Jan 2012 12:39:29 -0500 (EST)
Message-ID: <20120117.123929.1033968651111164006.davem@davemloft.net>
References: <1326570996-27818-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de, cavokz@gmail.com,
 kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
 linux-arm-kernel@lists.infradead.org
To: jaccon.bastiaansen@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1326570996-27818-1-git-send-email-jaccon.bastiaansen@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Date: Sat, 14 Jan 2012 20:56:36 +0100

> -	depends on ISA || EISA || MACH_IXDP2351 || ARCH_IXDP2X01 \
> -		|| MACH_MX31ADS || MACH_QQ2440 || (ARM && ARCH_EP93XX) || MAC
> +	depends on ISA || EISA || ARM || (ARM && ARCH_EP93XX) || MAC

The expression "ARM || (ARM && ARCH_EP93XX)" should be reduced to
just plain "ARM", which is equivalent.
