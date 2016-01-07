From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 06/26] phy: provide a hook for link up/link down events
Date: Thu, 07 Jan 2016 11:53:20 -0800
Message-ID: <568EC230.4070509@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjK-000750-5O@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36274 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbcAGTxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:53:54 -0500
Received: by mail-pa0-f51.google.com with SMTP id yy13so173774048pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:53:54 -0800 (PST)
In-Reply-To: <E1a5zjK-000750-5O@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> Sometimes, we need to do additional work between the PHY coming up and
> marking the carrier present - for example, we may need to wait for the
> PHY to MAC link to finish negotiation.  This changes phylib to provide
> a notification function pointer which avoids the built-in
> netif_carrier_on() and netif_carrier_off() functions.
> 
> Standard ->adjust_link functionality is provided by hooking a helper
> into the new ->phy_link_change method.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>


Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
