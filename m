From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: net: fec: Ensure clocks are enabled while using mdio bus
Date: Mon, 13 Jul 2015 15:40:00 +0800
Message-ID: <CAAQ0ZWStX30cCZR9Midzz-_0N7C=_pX3O=D4nwq0j1u5SxY2JA@mail.gmail.com>
References: <CANMBJr7XML6v5_75LmD7ARMHaAJo9YBodv13jCcdN2mL7Vu0ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Fugang Duan <B38611@freescale.com>,
	"Kevin's boot bot" <khilman@kernel.org>,
	Olof Johansson <olof@lixom.net>,
	netdev <netdev@vger.kernel.org>
To: Tyler Baker <tyler.baker@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANMBJr7XML6v5_75LmD7ARMHaAJo9YBodv13jCcdN2mL7Vu0ZQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 11, 2015 at 3:07 AM, Tyler Baker <tyler.baker@linaro.org> wrote:
> Hi Andrew,
>
> The kernelci.org system reported[1][2][3] new imx6 boot failures in
> next-20150710. I've bisected[4] these failures to 6c3e921b18ed "net:
> fec: Ensure clocks are enabled while using mdio bus". Reverting this
> commit on top of next-20150710, resolves the boot failures. I have not
> investigated any further, but did add the imx maintainer to the CC
> list. Apologies in advanced for not replying to the original thread,
> as I was not subscribed to the netdev list until now.

I just confirmed that the commit breaks my i.MX6Q board from booting here.

Shawn
