From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] ixgbe: Move ring features into an enum,
 allowing easier future maintenance
Date: Tue, 24 Feb 2009 16:37:01 -0800 (PST)
Message-ID: <20090224.163701.238043822.davem@davemloft.net>
References: <20090224234037.29312.54427.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752692AbZBYAhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 19:37:17 -0500
In-Reply-To: <20090224234037.29312.54427.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 24 Feb 2009 15:40:37 -0800

> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> The ring_feature member of ixgbe_adapter is statically allocated based on
> the supported features of the device.  When a new feature is added, we need
> to manually update the static allocation.  This patch makes the feature
> list an enum, eliminating the need for multiple updates to the code when
> adding a new feature.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

I would appreciate it if, in the future, Shannon would signoff his
patches :-)
