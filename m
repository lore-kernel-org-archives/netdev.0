From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 0/7] stmmac: dwmac-meson8b: configurable RGMII TX delay
Date: Fri, 25 Nov 2016 13:41:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0228643@AcuExch.aculab.com>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
 <20161125130156.17879-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
 "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "carlo@caione.org" <carlo@caione.org>,
 "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: 'Martin Blumenstingl' <martin.blumenstingl@googlemail.com>,
 "linux-amlogic@lists.infradead.org" <linux-amlogic@lists.infradead.org>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "davem@davemloft.net"
 <davem@davemloft.net>, "khilman@baylibre.com" <khilman@baylibre.com>,
 "mark.rutland@arm.com" <mark.rutland@arm.com>, "robh+dt@kernel.org"
 <robh+dt@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161125130156.17879-1-martin.blumenstingl@googlemail.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Martin Blumenstingl
> Sent: 25 November 2016 13:02
> Currently the dwmac-meson8b stmmac glue driver uses a hardcoded 1/4
> cycle TX clock delay. This seems to work fine for many boards (for
> example Odroid-C2 or Amlogic's reference boards) but there are some
> others where TX traffic is simply broken.
> There are probably multiple reasons why it's working on some boards
> while it's broken on others:
> - some of Amlogic's reference boards are using a Micrel PHY
> - hardware circuit design
> - maybe more...
...

Interesting thought.
Can you test phy loopback with different delays?
It might be then possible to default to 'auto'.

	David
