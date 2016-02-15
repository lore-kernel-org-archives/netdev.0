From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 10:22:14 -0800
Message-ID: <56C21756.1020702@gmail.com>
References: <1455558779-15953-1-git-send-email-clemens.gruber@pqgruber.com>
 <56C21695.1030809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Clemens Gruber <clemens.gruber@pqgruber.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33098 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbcBOSWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 13:22:17 -0500
In-Reply-To: <56C21695.1030809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15/02/2016 10:19, Florian Fainelli wrote:
> On 15/02/2016 09:52, Clemens Gruber wrote:
>> For the Marvell 88E1510, marvell_of_reg_init was called too late (in
>> m88e1510_config_aneg), which lead to the phy state machine being stuck
>> at waiting for interrupts, which are off by default on the 88E1510.
>> This further lead to the ethernet link not coming up at boot.
>> For some Marvell PHYs, marvell_of_reg_init was not called at all.
> 
> You could mention that this became apparent with

...
113c74d83eef ("net: phy: turn carrier off on phy attach")
