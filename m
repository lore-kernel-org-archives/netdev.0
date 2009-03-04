From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] Add support to FCoE offload through net_device
 (v2)
Date: Tue, 03 Mar 2009 23:57:25 -0800 (PST)
Message-ID: <20090303.235725.140764281.davem@davemloft.net>
References: <20090227220034.4987.50755.stgit.yi.zou@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: yi.zou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36128
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752853AbZCDH5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 02:57:41 -0500
In-Reply-To: <20090227220034.4987.50755.stgit.yi.zou@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>
Date: Fri, 27 Feb 2009 14:06:32 -0800

> This is set of revised patches for adding offload support of
> Fiber Channel over Ethernet (FCoE) offload support through net_device
> for the Open-FCoE project maintained at http://www.open-fcoe.org.
> 
> The original submission can be found at:
> http://marc.info/?l=linux-scsi&m=123507707821705&w=2
> 
> The included patches would add FCoE offload support through the net_device
> struct as shown in the series of patches followed here. This is achieved
> by adding nedev feature flags for FCoE FC CRC offload and large send offload
> through gso. The large receive offload by direct data placement (ddp) is
> achieved by the two function pointers to net_device_ops, to setup and release
> ddp context, ndo_fcoe_ddp_setup and ndo_fcoe_ddp_done. One data member is
> added to net_device strut, namely fcoe_ddp_xid, which inidates the maximum
> exchange id allowed by LLD to perform ddp on the read I/O request.
> 
> As the following patches touch both netdev and libfc/fcoe, and they are
> applicable to the current tip at www.open-fcoe.org w/ patches available at:
> http://marc.info/?l=linux-scsi&m=123576089125544&w=2 If they look alright,
> I will rework them later to be directly applicable to net-next, where the
> aforementioned fcoe/libfc fix patches are expected to be in kernel already
> through scsi-fixes.

I am fine with these changes, they look good.

