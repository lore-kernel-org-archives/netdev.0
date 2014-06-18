From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH net-next v2 1/3] ieee802154: cc2520: adds driver for TI
 CC2520 radio
Date: Wed, 18 Jun 2014 14:39:58 +0100
Message-ID: <20140618133958.GC11895@leverpostej>
References: <1403068565-32224-1-git-send-email-varkab@cdac.in>
 <1403068565-32224-2-git-send-email-varkab@cdac.in>
 <20140618091010.GB26461@leverpostej>
 <53A15B38.6060404@gmail.com>
 <20140618095519.GE26461@leverpostej>
 <53A17442.8010009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53A17442.8010009@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 18, 2014 at 12:13:06PM +0100, Varka Bhadram wrote:
> On 06/18/2014 03:25 PM, Mark Rutland wrote:
> > On Wed, Jun 18, 2014 at 10:26:16AM +0100, Varka Bhadram wrote:
> >> +static int cc2520_probe(struct spi_device *spi)
> >> +{
> >> +       struct cc2520_private *priv;
> >> +       struct pinctrl *pinctrl;
> >> +       struct cc2520_platform_data *pdata;
> >> +       struct device_node __maybe_unused *np =3D spi->dev.of_node=
;
> >>
> >> This looks to be definitely unused rather than __maybe_unused. The=
re are
> >> no other occuences of "np" in this function.
> >>
> >> This macro defined like this.
> >> #define __maybe_unused  __attribute__((unused))
> > Sure, but that's irrelevant. There's absolutely no point in this
> > variable existing at all, and it can simply disappear.
> >
> > Mark.
>=20
> If we don't use that macro the compiler triggers warnings saying that=
:  warning: unused variable =E2=80=98np=E2=80=99 [-Wunused-variable]

Then drop the _variable_, not just the annotation.

Mark.
