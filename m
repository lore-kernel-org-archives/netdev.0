From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] i40e: Fix dependencies in the i40e driver on
 configfs
Date: Tue, 03 Mar 2015 17:00:10 -0500 (EST)
Message-ID: <20150303.170010.1938054661367052407.davem@davemloft.net>
References: <1425417714-16929-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288AbbCCWAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 17:00:15 -0500
In-Reply-To: <1425417714-16929-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  3 Mar 2015 13:21:54 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Module dependencies are broken in the case where CONFIG_I40E=y and
> CONFIG_CONFIGFS_FS=m.  This fixes the broken dependency.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

That works better, applied, thanks.
