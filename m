From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
 2015-06-04
Date: Fri, 05 Jun 2015 21:17:53 -0700 (PDT)
Message-ID: <20150605.211753.1799384901949366986.davem@davemloft.net>
References: <1433474824-5414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbbFFEGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 00:06:46 -0400
In-Reply-To: <1433474824-5414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  4 Jun 2015 20:27:01 -0700

> This series contains updates to i40e and i40evf.
> 
> Anjali provides three fixes, first to resolve a Tx queue hang if mixed
> size frags are passed to the driver while using TSO.  There was a corner
> case where we needed to linearize but we were not.  Next fixes a bug in
> the default configuration which prevented a software bridge loaded on the
> PF interface from working correctly because broadcast packets are
> incorrectly looped back.  Lastly fixes an NPAR bug when SRIOV is enabled,
> where we need to be in VEB mode, not VEPA mode at probe.

Pulled, thanks Jeff.
