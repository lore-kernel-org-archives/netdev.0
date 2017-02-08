From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 0/2] net: phy: Unbind/bind fixes
Date: Tue, 7 Feb 2017 22:47:01 -0800
Message-ID: <fe3a0be5-dca4-c0d9-43b2-9da40394bfdc@gmail.com>
References: <20170205222557.24739-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        Russell King <rmk+kernel@armlinux.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35852 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752924AbdBHGsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 01:48:22 -0500
Received: by mail-oi0-f68.google.com with SMTP id u143so10341486oif.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 22:47:03 -0800 (PST)
In-Reply-To: <20170205222557.24739-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/05/2017 02:25 PM, Florian Fainelli wrote:
> Hi all,
> 
> This patch series addresses the inability to safely unbind and bind
> PHY drivers by making the appropriate checks throught PHYLIB where we
> may be directly responding to user-space queries, as well as from within
> the kernel state machine.
> 
> The second patch makes the unbind -> bind working by taking care of the
> PHY state machine state.

I need to make another set of fixes after "net: phy: Fix lack of
reference count on PHY driver" because the Generic PHY driver is of
course behaving differently and my testing was focused on every other
one but this one which is built-in...

> 
> Florian Fainelli (2):
>   net: phy: Check phydev->drv
>   net: phy: Fix PHY driver bind and unbind events
> 
>  drivers/net/phy/phy.c        | 26 ++++++++++++++++++++++----
>  drivers/net/phy/phy_device.c | 27 +++++++++++++++++++++++++--
>  include/linux/phy.h          |  3 +++
>  3 files changed, 50 insertions(+), 6 deletions(-)
> 

-- 
Florian
