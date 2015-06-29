From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: power on MII block for all MII modes
Date: Sun, 28 Jun 2015 20:27:39 -0700 (PDT)
Message-ID: <20150628.202739.1152355107671800451.davem@davemloft.net>
References: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
	<1435340314-10229-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbbF2D1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 23:27:40 -0400
In-Reply-To: <1435340314-10229-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 26 Jun 2015 10:38:31 -0700

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

This does not apply cleanly to the net tree, please respin.
