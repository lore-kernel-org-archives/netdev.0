From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] i40e: enable fdb add code, remove unused code
Date: Sat, 22 Nov 2014 16:56:59 -0500 (EST)
Message-ID: <20141122.165659.986635845194584299.davem@davemloft.net>
References: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbaKVV5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 16:57:02 -0500
In-Reply-To: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 20 Nov 2014 16:30:02 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The original FDB code submission wasn't correct and the code
> wasn't enabled.  This removes some dead code (can use the common kernel
> code for fdb_del and fdb_dump) and correctly enables the fdb_add
> function pointer.
> 
> The fdb_add functionality is important to i40e because it is needed
> for a workaround to allow bridges to work correctly on the i40e
> hardware.
> 
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Acked-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
