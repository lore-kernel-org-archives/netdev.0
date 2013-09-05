From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4] vxlan: Notify drivers for listening UDP port
 changes
Date: Thu, 05 Sep 2013 12:45:11 -0400 (EDT)
Message-ID: <20130905.124511.645325194173554268.davem@davemloft.net>
References: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joseph.gasparakis@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, john.r.fastabend@intel.com,
	stephen@networkplumber.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab3IEQpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 12:45:14 -0400
In-Reply-To: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  4 Sep 2013 02:13:38 -0700

> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> 
> This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
> ndo_del_rx_vxlan_port().
> 
> Drivers can get notifications through the above functions about changes
> of the UDP listening port of VXLAN. Also, when physical ports come up,
> now they can call vxlan_get_rx_port() in order to obtain the port number(s)
> of the existing VXLAN interface in case they already up before them.
> 
> This information about the listening UDP port would be used for VXLAN
> related offloads.
> 
> A big thank you to John Fastabend (john.r.fastabend@intel.com) for his
> input and his suggestions on this patch set.
> 
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
