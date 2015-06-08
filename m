From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: power on MII block for all MII modes
Date: Mon, 08 Jun 2015 12:16:11 -0700 (PDT)
Message-ID: <20150608.121611.1763355481306454170.davem@davemloft.net>
References: <1433785677-3817-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbbFHTQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:16:11 -0400
In-Reply-To: <1433785677-3817-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  8 Jun 2015 10:47:57 -0700

> The RGMII block is currently only powered on when using RGMII or
> RGMII_NO_ID, which is not correct when using the GENET interface in MII
> or Reverse MII modes. We always need to power on the RGMII interface for
> this block to properly work, regardless of the MII mode in which we
> operate.
> 
> Fixes: aa09677cba423 ("net: bcmgenet: add MDIO routines")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> David,
> 
> I am targetting "net" here since this is a bug fix, however, we have few
> people using MII or Reverse MII with GENET, such that there is no need to
> queue this for -stable unless you want to.

Ok, applied, thanks Florian.
