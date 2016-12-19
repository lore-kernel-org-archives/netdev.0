From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 4/4] arm64: dts: marvell: Add ethernet switch definition
 for the EXPRESSObin
Date: Mon, 19 Dec 2016 15:44:04 +0100
Message-ID: <20161219144404.GB10048@lunn.ch>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
 <20161219141610.30934-5-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Romain Perier <romain.perier@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20161219141610.30934-5-romain.perier@free-electrons.com>
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

> +		mdio {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <1>;
> +
> +			switch0phy0: switch0phy0@0 {
> +				reg = <0x11>;

Since the reg is 0x11, this should be called switch0phy0@11.  Please
follow the same scheme for the other phys.

       Andrew
