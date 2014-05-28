From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Wed, 28 May 2014 11:38:48 -0500
Message-ID: <CAL_Jsq+P2UJ8GMmGHX9FVs-a2o_3C-8wPTy653xcB-s8T+q1+Q@mail.gmail.com>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
	<1400875040-13269-2-git-send-email-sboyd@codeaurora.org>
	<20140524124858.GR22111@sirena.org.uk>
	<5385063F.30407@codeaurora.org>
	<20140528151646.GU20155@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Boyd <sboyd@codeaurora.org>,
	Mark Brown <broonie@kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Nishanth Menon <nm@ti.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Kumar Gala <galak@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140528151646.GU20155@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 28, 2014 at 10:16 AM, Uwe Kleine-K=C3=B6nig
<u.kleine-koenig@pengutronix.de> wrote:
> Hello Stephen,
>
> On Tue, May 27, 2014 at 02:40:15PM -0700, Stephen Boyd wrote:
>> On 05/24/14 05:48, Mark Brown wrote:
>> > On Fri, May 23, 2014 at 12:57:17PM -0700, Stephen Boyd wrote:
>> >
>> >>  Optional properties:
>> >> -- vdd-supply:     supply for Ethernet mac
>> >> +- vdd-supply: analog 3.3V supply for Ethernet mac
>> >> +- vdd-io-supply: digital 1.8V IO supply for Ethernet mac
>> > So, according to the datasheet I managed to find this device has a
>> > supply VDD_IO (so normally written vdd-io-supply here), some other
>> > supplies which are tied to VDD_IO (so can probably be omitted) and=
 a
>> > supply VDD_A3.3 none of which are optional.  There is an internal
>> > regulator which can be used to drop a higher voltage VDD_IO down f=
or
>> > some of the supplies tied to it but that's essentially a noop from
>> > software as far as I can tell.  None of these supplies are obvious=
ly
>> > optional, though I've not read the datasheet in detail so I may ha=
ve
>> > missed something here.
> There is a difference between the supply being optional for the hardw=
are
> to work and the need to specify it in the device tree, isn't it? My
> expectation is that when it's not specified there is just nothing the
> the software needs to care for.

Yes, agreed.

Of course you could have cases where a supply at the h/w level is
optional like if a supply can be powered externally or via an internal
regulator. Those cases will have to be made clear in the binding, but
a heading "Optional properties" in a binding doc means properties
which are optional to specify in DT.

Rob
