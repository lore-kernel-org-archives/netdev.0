From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/26] Phylink & SFP support
Date: Sun, 27 Dec 2015 17:56:11 -0800
Message-ID: <5F0394D6-EBD5-42E8-BD94-4D3065AA0EAB@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34016 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbL1B4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 20:56:17 -0500
Received: by mail-pa0-f46.google.com with SMTP id uo6so80274625pac.1
        for <netdev@vger.kernel.org>; Sun, 27 Dec 2015 17:56:16 -0800 (PST)
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On December 7, 2015 9:35:53 AM PST, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
>
>Overall, phylink supports several link modes, with dynamic switching
>possible between these:
>* A true fixed link mode, where the parameters are set by DT.
>* PHY mode, where we read the negotiation results from the PHY
>registers
>  and pass them to the NIC driver.
>* SGMII mode, where the in-band status indicates the speed, duplex and
>  flow control settings of the link partner.
>* 1000base-X mode, where the in-band status indicates only duplex and
> flow control settings (different, incompatible bit layout from SGMII.)
>
>Ethtool support is included, as well as emulation of the MII registers
>for situations where a PHY is not attached, giving compatible emulation
>of existing user interfaces where required.

This is looking really nice at first glance, I will provide feedback on each patches on the next few days, thanks!
Hello,
-- 
Florian
