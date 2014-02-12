From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 01/10] net: phy: add "internal" PHY mode
Date: Wed, 12 Feb 2014 18:35:00 +0400
Message-ID: <52FB8694.4080403@cogentembedded.com>
References: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com> <1392178053-3143-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, cernekee@gmail.com, devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35972 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbaBLOfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:35:03 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so7015253lbd.23
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 06:35:01 -0800 (PST)
In-Reply-To: <1392178053-3143-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-02-2014 8:07, Florian Fainelli wrote:

> On some systems, the PHY can be internal, in the same package as the
> Ethernet MAC, and still be responding to a specific address on the MDIO
> bus, in that case, the Ethernet MAC might need to know about it to
> properly configure a port multiplexer to switch to an internal or
> external PHY. Add a new PHY interface mode for this and update the
> Device Tree of_get_phy_mode() function to look for it.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

> @@ -553,7 +554,8 @@ static inline bool phy_interrupt_is_valid(struct phy_device *phydev)
>    */
>   static inline bool phy_is_internal(struct phy_device *phydev)
>   {
> -	return phydev->is_internal;
> +	return phydev->is_internal ||
> +		phydev->interface == PHY_INTERFACE_MODE_INTERNAL;

    Shouldn't the continuation line be aligned under 'phydev' on the borken up 
line)?

WBR, Sergei
