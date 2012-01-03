From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Tue, 03 Jan 2012 15:09:36 -0500 (EST)
Message-ID: <20120103.150936.572765552893657192.davem@davemloft.net>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873Ab2ACUJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:09:40 -0500
In-Reply-To: <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  3 Jan 2012 11:19:13 -0800

> +		e_err("Enabling both receive checksum offload and receive hashing is not possible with jumbo frames.  Disable jumbos or enable only one of the receive offload features.\n");

Please split this up into multiple lines like this:

	e_err("..."
	      "..."
	      "...");

Thanks.
