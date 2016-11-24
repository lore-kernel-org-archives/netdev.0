From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net-next PATCH v1 1/2] net: dt-bindings: add RGMII TX delay
 configuration to meson8b-dwmac
Date: Thu, 24 Nov 2016 16:48:58 +0100
Message-ID: <20161124154858.GB20455@lunn.ch>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
 <20161124143417.10178-2-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-amlogic@lists.infradead.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, davem@davemloft.net, khilman@baylibre.com,
        mark.rutland@arm.com, robh+dt@kernel.org,
        linux-arm-kernel@lists.infradead.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, carlo@caione.org, jbrunet@baylibre.com
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54366 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966602AbcKXPtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 10:49:03 -0500
Content-Disposition: inline
In-Reply-To: <20161124143417.10178-2-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The configuration values are provided as preprocessor macros to make the
> devicetree files easier to read.

Hi Martin

If i'm reading the code/comments correctly, you can set the delay to
0, 2, 4 or 6ns? So calling this property amlogic,tx-delay-ns would be
even easier to read.

     Andrew
