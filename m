From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [net-next PATCH v1 0/2] stmmac: dwmac-meson8b: configurable RGMII TX delay
Date: Fri, 25 Nov 2016 12:01:28 +0000
Message-ID: <yw1x60nbahuv.fsf@unicorn.mansr.com>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
        <1480002964.17538.131.camel@baylibre.com>
        <CAFBinCB7sXjXor++W+PW0-j_VxATRzhexjqHgXj2jD10tBpZFg@mail.gmail.com>
        <e6ca0941-e2e3-dd93-d4d3-8fbd76b60e17@gmail.com>
        <6a6af561-4e83-ca6e-d989-f421e18bce1e@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Jerome Brunet <jbrunet@baylibre.com>,
        linux-amlogic@lists.infradead.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, davem@davemloft.net, khilman@baylibre.com,
        mark.rutland@arm.com, robh+dt@kernel.org,
        linux-arm-kernel@lists.infradead.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, carlo@caione.org,
        Andrew Lunn <andrew@lunn.ch>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:41788 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750916AbcKYMC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 07:02:27 -0500
In-Reply-To: <6a6af561-4e83-ca6e-d989-f421e18bce1e@laposte.net> (Sebastian
        Frias's message of "Fri, 25 Nov 2016 12:13:32 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Frias <sf84@laposte.net> writes:

> On 24/11/16 19:55, Florian Fainelli wrote:
>> Le 24/11/2016 à 09:05, Martin Blumenstingl a écrit :
>>> Based on what I found it seems that rgmii-id, rgmii-txid and
>>> rgmii-rxid are supposed to be handled by the PHY.
>> 
>> Correct, the meaning of PHY_INTERFACE_MODE should be from the
>> perspective of the PHY device:
>> 
>> - PHY_INTERFACE_MODE_RGMII_TXID means that the PHY is responsible for
>> adding a delay when the MAC transmits (TX MAC -> PHY (delay) -> wire)
>> - PHY_INTERFACE_MODE_RGMII_RXID means that the PHY is responsible for
>> adding a delay when the MAC receives (RX MAC <- (delay) PHY) <- wire)
>> 
>
> Thanks for the explanation.
> Actually I had thought that the delay was to account for board routing
> (wires) between the MAC and the PHY.
> From your explanation it appears that the delay is to account for board
> routing (wires) between the PHY and the RJ45 socket.

The delay pertains to the RGMII link between MAC and PHY.  The external
connection is self-clocking.

-- 
Måns Rullgård
