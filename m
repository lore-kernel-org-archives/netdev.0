From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbevf: fix null pointer dereference due
 to filter being set for VLAN 0
Date: Mon, 02 Aug 2010 21:21:33 -0700 (PDT)
Message-ID: <20100802.212133.184833501.davem@davemloft.net>
References: <20100803005849.4678.10583.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754668Ab0HCEVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 00:21:15 -0400
In-Reply-To: <20100803005849.4678.10583.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 02 Aug 2010 17:59:04 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change corrects an issue that resulted in a null pointer dereference
> for the addition of VLAN 0 without any VLANs being registered.  Also this
> code removes some unnecessary checks for defines and the unnecessary setting
> of VLAN flags since that is now handled within the kernel via the
> vlan_features.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
