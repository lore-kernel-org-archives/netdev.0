From: Lukasz Majewski <lukma@denx.de>
Subject: Re: [PATCH] Documentation: devicetree: Add PHY no lane swap binding
Date: Mon, 6 Feb 2017 15:15:24 +0100
Message-ID: <20170206151524.2ff0f799@jawa>
References: <1486223267-11875-1-git-send-email-lukma@denx.de>
        <20170204172329.GA8364@lunn.ch>
        <509fadc4-164c-7333-1871-fd6e615e57c9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        jbrunet <jbrunet@baylibre.com>, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        Uwe =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?=
        <u.kleine-koenig@pengutronix.de>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Jon Mason <jon.mason@broadcom.com>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509fadc4-164c-7333-1871-fd6e615e57c9@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian, Andrew,

> Le 02/04/17 à 09:23, Andrew Lunn a écrit :
> > On Sat, Feb 04, 2017 at 04:47:47PM +0100, Lukasz Majewski wrote:
> >> Add the documentation to avoid PHY lane swapping. This is a boolean
> >> entry to notify the phy device drivers that the TX/RX lanes NO need
> > 
> > that the TX/RX lanes should not be swapped.
> > 
> >> to be swapped.
> >> The use case for this binding mostly happens after wrong HW
> >> configuration of PHY IC during bootstrap.
> >>
> >> Signed-off-by: Lukasz Majewski <lukma@denx.de>
> >> ---
> >>  Documentation/devicetree/bindings/net/phy.txt | 4 ++++
> >>  1 file changed, 4 insertions(+)
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/phy.txt
> >> b/Documentation/devicetree/bindings/net/phy.txt index
> >> fb5056b..5e25bc9 100644 ---
> >> a/Documentation/devicetree/bindings/net/phy.txt +++
> >> b/Documentation/devicetree/bindings/net/phy.txt @@ -39,6 +39,10 @@
> >> Optional Properties:
> >>  - enet-phy-lane-swap: If set, indicates the PHY will swap the
> >> TX/RX lanes to compensate for the board being designed with the
> >> lanes swapped. 
> >> +- enet-phy-lane-no-swap: If set, indicates that PHY will disable
> >> swap of the
> >> +  TX/RX lanes. This binding allows the PHY to work correcly after
> >> e.g. wrong
> >> +  bootstrap configuration caused by issues in PCB layout design.
> 
> s/binding/property/
> 
> >> +
> > 
> > We are leaving it undefined what it means if neither
> > enet-phy-lane-no-swap nor enet-phy-lane-swap properties are present.
> > Do we want to define this? That the swap should be left untouched by
> > the driver?
> 
> Since this is a description of the hardware, absence of a properties
> should mean that the driver is at freedom to either keep the hardware
> defaults, or come up with its own settings that are sensible for that
> particular PHY device.
> 
> What would you see clarified here?

Any more comments to this patch?

Is the explanation informative enough?


Best regards,

Lukasz Majewski

--

DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
