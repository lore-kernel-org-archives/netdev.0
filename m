From: Romain Perier <romain.perier@free-electrons.com>
Subject: Re: [PATCH v2 3/3] arm64: dts: marvell: Add ethernet switch
 definition for the ESPRESSObin
Date: Wed, 21 Dec 2016 09:57:55 +0100
Message-ID: <28dca2e8-64e2-a39b-600c-0530f03d988f@free-electrons.com>
References: <20161220085138.3998-1-romain.perier@free-electrons.com>
 <20161220085138.3998-4-romain.perier@free-electrons.com>
 <20161220154234.GC30952@lunn.ch>
 <c27998fd-3807-5c99-382b-b8d0d0f06526@free-electrons.com>
 <20161220161714.GD30952@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:53175 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757555AbcLUI6Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 03:58:24 -0500
In-Reply-To: <20161220161714.GD30952@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le 20/12/2016 à 17:17, Andrew Lunn a écrit :
>>>> +		mdio {
>>>> +			#address-cells = <1>;
>>>> +			#size-cells = <0>;
>>>> +			reg = <1>;
>>>
>>> what is this reg value for?
>>>
>>>     Andrew
>>>
>>
>> It was required to avoid a warning thrown by the mdio subsystem
>
> Do you remember what the warning was?
>
> This seems odd to me. I don't see why a reg is needed here.
>
> Thanks
> 	Andrew
>

Mhhh, in fact, I did changes to this mdio node, I relocated it...
the warning was probably before the relocation, because I no longer see 
it. So I have removed this reg value.

Thanks,
Romain
