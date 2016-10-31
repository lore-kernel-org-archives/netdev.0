From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [RFC PATCH 08/13] dwmac-meson8b: add support for phy selection
Date: Mon, 31 Oct 2016 15:23:29 +0100
Message-ID: <e1634bd6-ae3a-b757-4947-7884807457b8@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
 <1477060838-14164-9-git-send-email-narmstrong@baylibre.com>
 <20161021155408.GR16974@lunn.ch>
 <dc810494-6ece-c4ae-d412-ed9af3fac9c2@baylibre.com>
 <20161021160807.GT16974@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161021160807.GT16974@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2016 06:08 PM, Andrew Lunn wrote:
> Hi Neil
> 
>> Yes this would be a good idea if we were able to scan the internal
>> and external PHYs at the same time, but with our limited knowledge
>> the values we write in the register seems to switch a mux for the
>> whole RMII and MDIO signals to either interface.
> 
> Ah, O.K. So you need something like:
> 
> drivers/net/phy/mdio-mux-mmioreg.c
> 
> This seems to be limited to a single byte for the mux register, so you
> might need to make some extensions.
> 
>       Andrew
> 

Thanks for the hint, I will try to make use of this !

Neil
