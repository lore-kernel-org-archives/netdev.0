From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] be2net: patch set
Date: Wed, 02 Jul 2014 18:41:46 -0700 (PDT)
Message-ID: <20140702.184146.931095313472029442.davem@davemloft.net>
References: <1404113493-14851-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaGCBlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:41:47 -0400
In-Reply-To: <1404113493-14851-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 30 Jun 2014 13:01:29 +0530

> v2 change: merged 2 lines into one in patch 4
> 
> Patch 1 refactors be_cmd_get_profile_config() routine to reduce
> code duplication by using the be_cmd_notify_wait() routine, instead
> of using a separate variant of the code for MBOX and MCCQ.
> 
> Patch 2 introduces the required FW-cmd code in the PF to query
> RSS support on a VF. This is in preparation for patch 3.
> 
> Patch 3 adds support for the PF driver to re-configure the resource
> distribution in FW based on the number of VFs enabled by the user. When
> the user is not interested in enabling VFs, all resources of a port are
> set-aside for the PF. If less than maximum number of VFs are enabled, then
> each VF gets a better share of the resources and can now enable RSS (if
> the interface supports it.)
> 
> Patch 4 is a minor fix to re-enable HW vlan filtering as soon as the number
> of vlans programmed is within the HW limit.
> 
> Please consider applying to net-next tree. Thanks!

Series applied, thanks.
