From: David Miller <davem@davemloft.net>
Subject: Re: [net] vxlan: Fix sparse warnings
Date: Mon, 16 Sep 2013 00:54:18 -0400 (EDT)
Message-ID: <20130916.005418.1244442951270057033.davem@davemloft.net>
References: <1379082853-28172-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joseph.gasparakis@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab3IPEyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 00:54:20 -0400
In-Reply-To: <1379082853-28172-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 13 Sep 2013 07:34:13 -0700

> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> 
> This patch fixes sparse warnings when incorrectly handling the port number
> and using int instead of unsigned int iterating through &vn->sock_list[].
> Keeping the port as __be16 also makes things clearer wrt endianess.
> Also, it was pointed out that vxlan_get_rx_port() had unnecessary checks
> which got removed.
> 
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
