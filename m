From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 net-next] net: Define NETDEV_FCOE_WWNN,
 NETDEV_FCOE_WWPN only when CONFIG_LIBFCOE is enabled
Date: Sun, 28 Aug 2011 17:09:04 -0400 (EDT)
Message-ID: <20110828.170904.961380688718981558.davem@davemloft.net>
References: <1314387941-2126-1-git-send-email-mchan@broadcom.com>
	<1314387941-2126-2-git-send-email-mchan@broadcom.com>
	<1314387941-2126-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yi.zou@intel.com, bprakash@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266Ab1H1VJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 17:09:07 -0400
In-Reply-To: <1314387941-2126-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 26 Aug 2011 12:45:41 -0700

> From: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> 
> bnx2fc driver calls netdev->netdev_ops->ndo_fcoe_get_wwn() and it may not
> be defined with the current Kconfig dependencies.  ndo_fcoe_get_wwn is
> dependent on CONFIG_FCOE, but bnx2fc does not select CONFIG_FCOE, as it does
> not depend on fcoe driver. Since both fcoe and bnx2fc drivers select
> CONFIG_LIBFCOE, define NETDEV_FCOE_WWNN and NETDEV_FCOE_WWPN when
> CONFIG_LIBFCOE is defined.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Cc: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
