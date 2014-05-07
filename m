From: Fabio Estevam <festevam@gmail.com>
Subject: Re: i.MX28 based system losing eth0 on boot
Date: Wed, 7 May 2014 00:17:07 -0300
Message-ID: <CAOMZO5C4GiLu3sGPxuEDX+cVOvXsk=z9iqLSvZX8HzpncJuJOw@mail.gmail.com>
References: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Brian Lilly <brian@crystalfontz.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian,

On Tue, May 6, 2014 at 1:44 PM, Brian Lilly <brian@crystalfontz.com> wrote:
> Uwe:
>
> With commit a264b981f2c76e281ef27e7232774bf6c54ec865 we're having eth0
> come up, then brought right back down with an MDIO rx timeout moments
> after.  Adding back in the removed code keeps the interface alive and
> it's working afterward without trouble.  I've tested the re-inserted
> code in 3.12, 3.14 without issue on our boards.
>
> Is there something else that can be done to prevent the MDIO timeouts?
> We are using basically the same schematic for networking as the
> imx28evk.
>
> Any thoughts on how to resolve this?

Could you try the latest Russell's FEC patches available at?
 http://ftp.arm.linux.org.uk/cgit/linux-arm.git/log/?h=fec-testing

In particular this one could help with your "MDIO timeout" issue:
http://ftp.arm.linux.org.uk/cgit/linux-arm.git/commit/?h=fec-testing&id=ec1fac3de70b16c69d3edc9f223e91d56b1915de
