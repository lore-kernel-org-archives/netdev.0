From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/3] ixgbe: Correctly disable VLAN filter in promiscuous
 mode
Date: Sun, 23 Nov 2014 14:26:59 -0500 (EST)
Message-ID: <20141123.142659.1015994366326439091.davem@davemloft.net>
References: <1416642774-17077-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com, stable@vger.kernel.org,
	jacob.e.keller@intel.com, vyasevic@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbaKWT1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 14:27:02 -0500
In-Reply-To: <1416642774-17077-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2014 23:52:52 -0800

> From: Vlad Yasevich <vyasevich@gmail.com>
> 
> IXGBE adapter seems to require that VLAN filtering be enabled if
> VMDQ or SRIOV are enabled.  When those functions are disabled,
> VLAN filtering may be disabled in promiscuous mode.
> 
> Prior to commit a9b8943ee129 ("ixgbe: remove vlan_filter_disable
> and enable functions")
> 
> The logic was correct.  However, after the commit the logic
> got reversed and VLAN filtered in now turned on when VMDQ/SRIOV
> is disabled.
> 
> This patch changes the condition to enable hw vlan filtered
> when VMDQ or SRIOV is enabled.
> 
> Fixes: a9b8943ee129 ("ixgbe: remove vlan_filter_disable and enable functions")
> Cc: stable <stable@vger.kernel.org>
> CC: Jacob Keller <jacob.e.keller@intel.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
