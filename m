From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB
 ageing in SW or HW
Date: Wed, 25 Feb 2015 12:29:33 -0500 (EST)
Message-ID: <20150225.122933.847453144328568960.davem@davemloft.net>
References: <54E8CE77.3050709@cumulusnetworks.com>
	<CAE4R7bAPS1GZKaC4M6x9cqfTOkVju1+Po4KzanfSniEFX9oi1w@mail.gmail.com>
	<20150225143113.GD17992@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, roopa@cumulusnetworks.com,
	vbandaru@broadcom.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	gospo@cumulusnetworks.com, siva.mannem.lnx@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbbBYR3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:29:38 -0500
In-Reply-To: <20150225143113.GD17992@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 25 Feb 2015 15:31:13 +0100

> I don't think this is going to work. There is no efficient way to get
> the hardware tables out of the hardware. We don't get notification of
> additions or removals. We can only read the whole table. And it can be
> expensive to read the whole table, since it can be 1K or more entries,
> going over an MDIO bus, which in the worst case can be bit banging on
> gpio lines.

Agreed, for most chips, this is how things seem to be structured.
