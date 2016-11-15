From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement disable
 options
Date: Tue, 15 Nov 2016 17:30:36 +0100
Message-ID: <20161115163036.GB23231@lunn.ch>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
 <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40554 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753261AbcKOQbL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 11:31:11 -0500
Content-Disposition: inline
In-Reply-To: <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 03:29:12PM +0100, Jerome Brunet wrote:
> On some platforms, energy efficient ethernet with rtl8211 devices is
> causing issue, like throughput drop or broken link.
> 
> This was reported on the OdroidC2 (DWMAC + RTL8211F). While the issue root
> cause is not fully understood yet, disabling EEE advertisement prevent auto
> negotiation from enabling EEE.
> 
> This patch provides options to disable 1000T and 100TX EEE advertisement
> individually for the realtek phys supporting this feature.

Looking at the code, i don't see anything specific to RealTek
here. This all seems generic. So should it be in phy.c and made a
generic OF property which can be applied to any PHY which supports
EEE.

      Andrew
