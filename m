From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] be2net: patch set
Date: Sat, 02 Aug 2014 15:59:52 -0700 (PDT)
Message-ID: <20140802.155952.1353023170138009635.davem@davemloft.net>
References: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaHBW7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:59:53 -0400
In-Reply-To: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 1 Aug 2014 17:47:29 +0530

> Patch 1 fixes a regression caused by a previous commit on net-next.
> Old versions of BE3 FW may not support cmds to re-provision (and hence
> optimize) resources/queues in SR-IOV config. Do not treat this FW cmd
> failure as fatal and fail the function initialization. Instead, just
> enable SR-IOV with the resources provided by the FW.
> 
> Patch 2 ignores a VF mac address setting if the new mac is already active
> on the VF.
> 
> Patch 3 adds support to delete a FW-dump via ethtool on Lancer adapters.
> 
> Please consider applying this patch-set to the net-next tree. Thanks!

Series applied, thank you.
