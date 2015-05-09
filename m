From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: fec: add support of ethtool get_regs
Date: Sun, 10 May 2015 00:16:21 +0200
Message-ID: <554E8735.302@gmail.com>
References: <1431204728-16754-1-git-send-email-tremyfr@gmail.com> <20150509211746.GY2067@n2100.arm.linux.org.uk> <CAOMZO5A2POPCYHzotc5SEhtmCuBrXiK7bdjF=UeiXZEqcnGMag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	=?UTF-8?B?TG90aGFyIFdhw59tYW5u?= <LW@karo-electronics.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5A2POPCYHzotc5SEhtmCuBrXiK7bdjF=UeiXZEqcnGMag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fabio,

On 09/05/15 23:59, Fabio Estevam wrote:
> Philippe,
>
> On Sat, May 9, 2015 at 6:17 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk>  wrote:
>
>> Using memcpy_fromio() to copy device registers is not a good idea -
>> it can use a variable access size which can cause bus faults.
>
> An example on how memcpy_fromio() can be avoided in get_regs:
> drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c

Thanks for pointing me this example. I've already send a patch,
and I've used drivers/net/ethernet/freescale/gianfar_ethtool.c
as example. I hope it's a good example too.

> Regards,
>
> Fabio Estevam

Regards,
Philippe
