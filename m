From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/3] net: phy: leds: Break dependency of phy.h on
 phy_led_triggers.h
Date: Wed, 25 Jan 2017 13:50:46 +0100
Message-ID: <20170125125046.GA2504@lunn.ch>
References: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
 <1485340790-10785-3-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Magnus =?iso-8859-1?Q?=D6berg?= <magnus.oberg@westermo.se>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45318 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751391AbdAYMuz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 07:50:55 -0500
Content-Disposition: inline
In-Reply-To: <1485340790-10785-3-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 11:39:49AM +0100, Geert Uytterhoeven wrote:
> <linux/phy.h> includes <linux/phy_led_triggers.h>, which is not really
> needed.  Drop the include from <linux/phy.h>, and add it to all users
> that didn't include it explicitly.
> 
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
