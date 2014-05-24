From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 0/3] mdio: Parse DT nodes for auto-probed PHYs
Date: Sat, 24 May 2014 09:34:24 +0200
Message-ID: <1400916867-24573-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com, Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34128 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaEXHek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 03:34:40 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so1827985wib.17
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 00:34:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Here's v2.

v1 -> v2:
	* Switch to of_property_read_u32() in patch #1
	* Check for mdio->dev_of_node in patch #2
	* Added Florian's Reviewed-by: tags

Thanks!
Daniel

Daniel Mack (3):
  net: of_mdio: factor out code to parse a phy's 'reg' property
  net: of_mdio: add of_mdiobus_link_phydev()
  net: of_mdio: don't store the length of a property if we don't need to

 drivers/net/phy/mdio_bus.c |  6 ++++
 drivers/of/of_mdio.c       | 72 +++++++++++++++++++++++++++++++++++++---------
 include/linux/of_mdio.h    |  8 ++++++
 3 files changed, 72 insertions(+), 14 deletions(-)

-- 
1.9.0
