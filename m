From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: dsa: Remove redundant phy_attach()
Date: Mon, 09 Feb 2015 14:06:05 -0800 (PST)
Message-ID: <20150209.140605.383021111937070414.davem@redhat.com>
References: <1423445395-412-1-git-send-email-andrew@lunn.ch>
	<54D908B6.9020101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371AbbBIWGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 17:06:16 -0500
In-Reply-To: <54D908B6.9020101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 09 Feb 2015 11:21:26 -0800

> On 08/02/15 17:29, Andrew Lunn wrote:
>> dsa_slave_phy_setup() finds the phy for the port via device tree and
>> using of_phy_connect(), or it uses the fall back of taking a phy from
>> the switch internal mdio bus and calling phy_connect_direct(). Either
>> way, if a phy is found, phy_attach_direct() is called to attach the
>> phy to the slave device.
>> 
>> In dsa_slave_create(), a second call to phy_attach() is made. This
>> results in the warning "PHY already attached". Remove this second,
>> redundant attaching of the phy.
>> 
>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
