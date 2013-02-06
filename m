From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] tg3: add support for Ethernet core in BCM4785
Date: Wed, 06 Feb 2013 15:01:11 -0500 (EST)
Message-ID: <20130206.150111.1099392598722136056.davem@davemloft.net>
References: <1360170854-32029-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757962Ab3BFUBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:01:14 -0500
In-Reply-To: <1360170854-32029-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Wed,  6 Feb 2013 18:14:10 +0100

> These patches are adding support for the Ethernet core found in the 
> BCM4705/BCM4785 SoC.
> 
> This is based on current master of davem/net-next.git.
> 
> v2:
>  * use of struct sprom in ssb_gige_get_macaddr() instead of accessing 
>    the nvram directly
>  * add return value to ssb_gige_get_macaddr()
>  * try to read the mac address from ssb core before accessing the own 
>    registers.
>  * fix two checkpatch warnings

You should combine the first two patches into one patch.

Please do so and respin this series, thanks.
