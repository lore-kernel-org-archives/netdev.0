From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] ixgbe: Defeature Tx Head writeback
Date: Fri, 06 Feb 2009 21:47:40 -0800 (PST)
Message-ID: <20090206.214740.223082457.davem@davemloft.net>
References: <20090206224424.28541.494.stgit@lost.foo-projects.org>
	<20090206224447.28541.40271.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44460
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752285AbZBGFrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 00:47:43 -0500
In-Reply-To: <20090206224447.28541.40271.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 06 Feb 2009 14:44:47 -0800

> Tx Head writeback is causing multi-microsecond stalls on PCIe chipsets, due
> to partial cacheline writebacks.  Removing this feature removes these
> issues.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Also applied, thanks!
