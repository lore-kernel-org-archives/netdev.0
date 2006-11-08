From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] Add support for configuring the PHY connection interface
Date: Wed, 8 Nov 2006 00:27:19 -0600
Message-ID: <8B9923C9-B6BC-49CA-870F-A3635C9D3507@freescale.com>
References: <Pine.LNX.4.61.0611080009010.6936@ld0175-tx32.am.freescale.net> <EA9DED93-76A1-48F8-A31D-F1B95CBA5040@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:20683 "EHLO
	az33egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1753134AbWKHG2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 01:28:52 -0500
In-Reply-To: <EA9DED93-76A1-48F8-A31D-F1B95CBA5040@kernel.crashing.org>
To: Kumar Gala <galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 8, 2006, at 00:16, Kumar Gala wrote:

>
> On Nov 8, 2006, at 12:10 AM, Andy Fleming wrote:
>
>> Most PHYs connect to an ethernet controller over a GMII or MII
>> interface.  However, a growing number are connected over
>> different interfaces, such as RGMII or SGMII.
>>
>> The ethernet driver will tell the PHY what type of connection it
>> is by setting it manually, or passing it in through phy_connect
>> (or phy_attach).
>>
>> Changes include:
>> * Updates to documentation
>> * Updates to other PHY Lib consumers
>> * Changes to PHY Lib to add interface support
>> * Some minor changes to whitespace in phy.h
>> * interface values now passed to gianfar
>>
>> Signed-off-by: Andrew Fleming <afleming@freescale.com>
>
> Any reason to not make interface an enum?

I became mildly attached to the notion of having a "reduced" bit.

I'd be open to changing it.
