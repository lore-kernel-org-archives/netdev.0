From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: disable toggling of rxvlan if necessary
Date: Fri, 27 Feb 2015 17:40:06 -0500 (EST)
Message-ID: <20150227.174006.172927575385261953.davem@davemloft.net>
References: <1424958487-5737-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932494AbbB0WkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:40:08 -0500
In-Reply-To: <1424958487-5737-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 26 Feb 2015 14:48:07 +0100

> The bnx2 driver uses .ndo_fix_features to force enable of Rx VLAN tag
> stripping when the card cannot disable it. The driver should remove
> NETIF_F_HW_VLAN_CTAG_RX flag from hw_features instead so it is fixed
> for the ethtool.
> 
> Cc: Sony Chacko <sony.chacko@qlogic.com>
> Cc: Dept-HSGLinuxNICDev@qlogic.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Would be great to get some reviews from the qlogic folks.
