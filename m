From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: add support of ethtool get_regs
Date: Sat, 9 May 2015 18:59:01 -0300
Message-ID: <CAOMZO5A2POPCYHzotc5SEhtmCuBrXiK7bdjF=UeiXZEqcnGMag@mail.gmail.com>
References: <1431204728-16754-1-git-send-email-tremyfr@gmail.com>
	<20150509211746.GY2067@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Philippe Reynes <tremyfr@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	=?UTF-8?Q?Lothar_Wa=C3=9Fmann?= <LW@karo-electronics.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150509211746.GY2067@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philippe,

On Sat, May 9, 2015 at 6:17 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:

> Using memcpy_fromio() to copy device registers is not a good idea -
> it can use a variable access size which can cause bus faults.

An example on how memcpy_fromio() can be avoided in get_regs:
drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c

Regards,

Fabio Estevam
