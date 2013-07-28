From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/2] igb: fix vlan filtering in promisc mode when not in
 VT mode
Date: Sun, 28 Jul 2013 13:17:50 -0700 (PDT)
Message-ID: <20130728.131750.1700424516115373731.davem@davemloft.net>
References: <1374842796-28445-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1374842796-28445-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3G1URv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 16:17:51 -0400
In-Reply-To: <1374842796-28445-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Jul 2013 05:46:36 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch fixes a VT mode check to make sure VLAN filters are disabled when
> in promisc mode and VT is not enabled.
> 
> The problem with the previous check was that:
> E1000_MRQC_ENABLE_VMDQ is defined as 0x00000003
> 
> but when not in VT mode:
> mrqc |= E1000_MRQC_ENABLE_RSS_4Q (0x00000002)
> 
> So the above check will trigger regardless if VT mode is being used or not.
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
