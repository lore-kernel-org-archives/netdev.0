From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Buggy cable detection on i.MX51, fec driver and LAN8700 PHY
Date: Mon, 27 Jul 2015 22:51:21 -0300
Message-ID: <CAOMZO5CKVR7xTjGwiGQtnbj6_LiJpB8Fa2QtdAbMNHGXa4GdXw@mail.gmail.com>
References: <55B6453C.10500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Joe Perches <joe@perches.com>,
	Luwei Zhou <b45643@freescale.com>,
	Duan Fugang-B38611 <b38611@freescale.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	=?UTF-8?Q?Lothar_Wa=C3=9Fmann?= <LW@karo-electronics.de>,
	Frank Li <Frank.Li@freescale.com>
To: plyatov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B6453C.10500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2015 at 11:50 AM, Igor Plyatov <plyatov@gmail.com> wrote:
> Dear all,
>
> very often we observe issue with Ethernet cable detection during cable
> unplugging and plugging.
>
> We use Voipac i.MX51 SOMs (System On Modules). They are based on Freescale
> i.MX51 CPU with LAN7800 PHY in MII mode. The schematic of PHY connection is
> very similar to the Freescale i.MX51 Babbage board.
>
> The Ethernet interface eth0 is configured statically for simplicity, but
> same issue exists with DHCP configuration.
>
> I did a lot of tests to determine stability of Ethernet cable detection by
> the "fec" Ethernet driver.
>
> In normal operation, if I unplug the Ethernet cable, then "fec" driver
> prints "fec 83fec000.ethernet eth0: Link is Down" and green LED (Ethernet
> medium detected) is OFF.
> If I plug cable back, then "fec" driver print "fec 83fec000.ethernet eth0:
> Link is Up - 100Mbps/Full - flow control off" and green LED is ON.
>
> But sometimes, after cable plugging, "fec" driver does not print anything on
> the console and green LED does not show detection of Ethernet cable.
> Frequency of issue appearing is a random value. Sometimes issue appears
> after second cable unplugging/plugging, but sometimes - after 10-20
> unplugging/plugging.
>
> The issue was tested and exists on kernels from linux-3.8.5 till current
> linux-4.2-rc4-cbfe8fa6cd672011c755c3cd85c9ffd4e2d10a6f.
>
> Same tests was made with different versions of the Barebox bootloader and
> cable detection works flawless.
>
> Please, help to resolve issue with Linux drivers.

I tried linux-next on a imx51-babbage and could not reproduce the problem here.

Regards,

Fabio Estevam
