From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH v5 01/10] arm64: dts: allwinner: Restore EMAC changes
Date: Fri, 8 Sep 2017 15:39:04 +0800
Message-ID: <CAGb2v64K3XTLJwZwYmq3r64=3_bHHGTeGyC0gfoJfL5+Ty53ag@mail.gmail.com>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-2-clabbe.montjoie@gmail.com> <20170908071954.j2bhtw4wqa27fald@flea.lan>
 <20170908073657.GA29999@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Chen-Yu Tsai <wens@csie.org>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908073657.GA29999@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 8, 2017 at 3:36 PM, Corentin Labbe
<clabbe.montjoie@gmail.com> wrote:
> On Fri, Sep 08, 2017 at 09:19:54AM +0200, Maxime Ripard wrote:
>> On Fri, Sep 08, 2017 at 09:11:47AM +0200, Corentin Labbe wrote:
>> > diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
>> > index 1c2387bd5df6..968908761194 100644
>> > --- a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
>> > +++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
>> > @@ -50,6 +50,7 @@
>> >     compatible = "friendlyarm,nanopi-neo2", "allwinner,sun50i-h5";
>> >
>> >     aliases {
>> > +           ethernet0 = &emac;
>> >             serial0 = &uart0;
>> >     };
>> >
>> > @@ -108,6 +109,22 @@
>> >     status = "okay";
>> >  };
>> >
>> > +&emac {
>> > +   pinctrl-names = "default";
>> > +   pinctrl-0 = <&emac_rgmii_pins>;
>> > +   phy-supply = <&reg_gmac_3v3>;
>> > +   phy-handle = <&ext_rgmii_phy>;
>> > +   phy-mode = "rgmii";
>> > +   status = "okay";
>> > +};
>> > +
>> > +&mdio {
>> > +   ext_rgmii_phy: ethernet-phy@7 {
>> > +           compatible = "ethernet-phy-ieee802.3-c22";
>> > +           reg = <7>;
>> > +   };
>> > +};
>> > +
>>
>> This won't compile, you don't have that node in the H5 DTSI.
>>
>
> Since H5 DTSI include arm/sunxi-h3-h5.dtsi it compiles.
> Furthermore, I restested just now and confirm, it compiles fine.

The order of your patches are wrong. No individual patch should
introduce build failures, not just the whole patch series.

ChenYu
