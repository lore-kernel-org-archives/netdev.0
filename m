From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Audit drivers to identify those needing
 IFF_TX_SKB_SHARING cleared
Date: Wed, 27 Jul 2011 22:42:22 -0700 (PDT)
Message-ID: <20110727.224222.415740695646226639.davem@davemloft.net>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	<1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
	<1311696338-4739-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net, khc@pm.waw.pl,
	linville@tuxdriver.com, gregkh@suse.de, marcel@holtmann.org,
	johannes@sipsolutions.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658Ab1G1Fp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:45:57 -0400
In-Reply-To: <1311696338-4739-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 26 Jul 2011 12:05:38 -0400

> After the last patch, We are left in a state in which only drivers calling
> ether_setup have IFF_TX_SKB_SHARING set (we assume that drivers touching real
> hardware call ether_setup for their net_devices and don't hold any state in
> their skbs.  There are a handful of drivers that violate this assumption of
> course, and need to be fixed up.  This patch identifies those drivers, and marks
> them as not being able to support the safe transmission of skbs by clearning the
> IFF_TX_SKB_SHARING flag in priv_flags
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
