From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] can: xilinx CAN controller support.
Date: Tue, 11 Feb 2014 15:12:45 +0100
Message-ID: <201402111512.45678.arnd@arndb.de>
References: <6c2bcce0-9897-4d1d-a8b9-47924e40f73c@VA3EHSMHS008.ehs.local> <52FA1910.2060101@pengutronix.de> <52FA2419.70102@monstr.eu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Marc Kleine-Budde" <mkl@pengutronix.de>,
	Michal Simek <michal.simek@xilinx.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: monstr@monstr.eu
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52FA2419.70102@monstr.eu>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 11 February 2014, Michal Simek wrote:
> >> The only remaining question is if we should create generic DT binding
> >> for fifo depth. Arnd, Rob: Any opinion about it?
> >> Definitely will be worth to have one generic binding if this is generic feature.
> >> But if this is just specific feature for us then current properties should
> >> be fine.
> >>
> >> In general all these xlnx,XXX properties just reflect all configurable options
> >> which you can setup in design tool which means that provide full hw description
> >> with all variants and they are automatically generated from tools.
> >>
> >> Please let me know what you think.
> > 
> > I like:
> > 
> >     rx-fifo-depth
> >     tx-fifo-depth
> 
> No problem with that. Let Kedar to fix it according this and he will send v2 with this.
> 

Sounds reasonable to me too.

	Arnd
