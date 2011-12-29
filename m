From: Florian Fainelli <florian@openwrt.org>
Subject: Allocation of MDIO bus numbers when fixed MDIO bus is enabled?
Date: Thu, 29 Dec 2011 17:09:44 +0100
Message-ID: <4EFC90C8.1060802@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: afleming@freescale.com, netdev@vger.kernel.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48990 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944Ab1L2QKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 11:10:42 -0500
Received: by wgbdr13 with SMTP id dr13so23398427wgb.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 08:10:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andy,

An user of the r6040 driver has enabled support for the Fixed MDIO bus, 
so when the r6040 registers with its first instance, it will also try to 
register a MDIO bus with id 0, and this fails.

What's the proper solution to fixing this kind of issue? The same user 
proposed to use the pci slot and function as an id for registering the 
MDIO bus, which will work for PCI devices, but not for platform_devices 
for instance.

Thanks.
--
Florian
