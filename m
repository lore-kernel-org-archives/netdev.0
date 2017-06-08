From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 9/9] arm64: marvell: dts: add xmdio nodes for 7k/8k
Date: Thu, 08 Jun 2017 10:55:01 +0200
Message-ID: <8737barh96.fsf@free-electrons.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
        <20170607083810.30922-10-antoine.tenart@free-electrons.com>
        <20170608084515.GA12385@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47565 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdFHIzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 04:55:13 -0400
In-Reply-To: <20170608084515.GA12385@kwain> (Antoine Tenart's message of "Thu,
        8 Jun 2017 10:45:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Antoine,
 
 On jeu., juin 08 2017, Antoine Tenart <antoine.tenart@free-electrons.com> wrote:

> Hi Gregory,
>
> On Wed, Jun 07, 2017 at 10:38:10AM +0200, Antoine Tenart wrote:
>> diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
>> index 2a99ff8fca2a..594356243ddb 100644
>> --- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
>> +++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
>> @@ -103,6 +103,13 @@
>>  				clocks = <&cps_syscon0 1 9>, <&cps_syscon0 1 5>;
>>  			};
>>  
>> +			cps_xmdio: mdio@12a600 {
>> +				#address-cells = <1>;
>> +				#size-cells = <0>;
>> +				compatible = "marvell,xmdio";
>> +				reg = <0x12a600 0x10>;
>> +			};
>> +
>
> Russell pointed out on IRC the mdio/xmdio interfaces aren't wired to
> anything on the mcbin. We could either disable these interfaces by
> default, or add explicit disables in the mcbin device tree.
>
> What's your thoughts on this?

I prefer that we disable it by default and only enable it on the boards
using it.

Thanks,

Gregory

>
> Thanks!
> Antoine
>
> -- 
> Antoine Ténart, Free Electrons
> Embedded Linux and Kernel engineering
> http://free-electrons.com

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
