From: David Binderman <dcb314@hotmail.com>
Subject: drivers/net/phy/dp83867.c:167: possible bad if ?
Date: Mon, 20 Jul 2015 12:37:38 +0000
Message-ID: <DUB128-W6216BE4A8E21E94EEB06DE9C850@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc1s17.hotmail.com ([157.55.0.216]:53986 "EHLO
	DUB004-OMC1S17.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752193AbbGTMhk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 08:37:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

drivers/net/phy/dp83867.c:167:57: warning: logical =91or=92 of collecti=
vely exhaustive tests is always true [-Wlogical-op]

Source code is

=A0=A0=A0 if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) ||
=A0=A0=A0=A0=A0=A0=A0 (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_=
RXID)) {

Maybe

=A0=A0=A0 if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) &&
=A0=A0=A0=A0=A0=A0=A0 (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_=
RXID)) {


Regards

David Binderman

 		 	   		  