From: Michael Riesch <michael@riesch.at>
Subject: Re: SMSC 8720a/MDIO/PHY help.
Date: Wed, 13 Apr 2011 23:19:24 +0200
Message-ID: <1302729564.2742.28.camel@malcolm>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com>
Reply-To: michael@riesch.at
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay03.ispgateway.de ([80.67.31.37]:37511 "EHLO
	smtprelay03.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758336Ab1DMVU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 17:20:28 -0400
In-Reply-To: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> If you have an idea of something for me to try, I'd love to entertain
> it.

I am rather new to PHYLIB, but these are my ideas:

 1) make sure phy_connect is executed (AFIAK called by MDIO bus driver)

 2) maybe you need to call phy_start / phy_stop (AFAIK from the PHY
driver's open / close function)

HTH,
Michael

