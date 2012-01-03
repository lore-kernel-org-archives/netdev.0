From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 07/11] e1000e: cleanup Rx checksum offload code
Date: Tue, 03 Jan 2012 15:08:42 -0500 (EST)
Message-ID: <20120103.150842.1516759599032629705.davem@davemloft.net>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1325618356-2655-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731Ab2ACUIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:08:45 -0500
In-Reply-To: <1325618356-2655-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  3 Jan 2012 11:19:12 -0800

> -		__sum16 sum = (__force __sum16)htons(csum);
> +		__sum16 sum = (__force __sum16)htons(le16_to_cpu(csum));

Looks like a NOP.  It's essentially "cpu_to_le16(le16_to_cpu(csum)" as
far as I can tell.
