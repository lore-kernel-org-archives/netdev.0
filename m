From: David Binderman <dcb314@hotmail.com>
Subject: RE: drivers/net/phy/dp83867.c:167: possible bad if ?
Date: Mon, 20 Jul 2015 18:00:24 +0000
Message-ID: <DUB128-W71C785FB2C2E811A329E859C850@phx.gbl>
References: <DUB128-W6216BE4A8E21E94EEB06DE9C850@phx.gbl>
 <55AD2FC6.60508@gmail.com> <55AD31E1.6010506@ti.com>
 <55AD328A.9040106@gmail.com>,<55AD3542.7080906@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Dan Murphy <dmurphy@ti.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc1s12.hotmail.com ([157.55.0.211]:50675 "EHLO
	DUB004-OMC1S12.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755330AbbGTSA0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 14:00:26 -0400
In-Reply-To: <55AD3542.7080906@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

----------------------------------------
> The proposed fix is logically correct. And it matches the code for
> phy_interface_is_rgmii with the '&&'.

As the original warning message indicates, I used compiler flag
-Wlogical-op to find this problem.

In order to detect this problem in future in your section of
the Linux kernel, it might be a wise idea to add compiler flag
-Wlogical-op to your builds.

If all goes well, this extra compiler flag should have nothing to say.

Just an idea.


Regards

David Binderman

 		 	   		  