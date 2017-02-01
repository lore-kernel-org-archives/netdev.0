From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next] net: phy: Add LED mode driver for Microsemi
Date: Wed, 1 Feb 2017 10:04:08 -0800
Message-ID: <6e89a748-f3ca-022f-032f-7fc45c68482d@gmail.com>
References: <1485953626-25780-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Allan.Nielsen@microsemi.com, andrew@lunn.ch
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36211 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdBASEL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 13:04:11 -0500
In-Reply-To: <1485953626-25780-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2017 04:53 AM, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> LED Mode:
> Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
> status information that can be selected by setting LED mode.

Why is this LED selection done through Device Tree/initial configuration
instead of coming up with a proper LED device registered by the PHY
which allows you to select exactly how you want the modes to wind-up
looking like?

NB: you don't need a cover letter for single patches.

> 
> LED Mode parameter (vsc8531, led-0-mode) and (vsc8531, led-1-mode) get from
> Device Tree.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Change set:
> v0:
> - Initial version of LED driver for Microsemi PHYs.
> v1:
> - Update all review comments given by Andrew.
> - Add new header file "mscc-phy-vsc8531.h" to define DT macros.
> - Add error/range check for DT LED mode input
> v2:
> - Fixed x86_64 build error.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> 
> Raju Lakkaraju (1):
>   net: phy: Add LED mode driver for Microsemi PHYs.
> 
>  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 10 +++
>  drivers/net/phy/mscc.c                             | 85 +++++++++++++++++++++-
>  include/dt-bindings/net/mscc-phy-vsc8531.h         | 29 ++++++++
>  3 files changed, 123 insertions(+), 1 deletion(-)
>  create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h
> 


-- 
Florian
