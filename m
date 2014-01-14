From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] make skb_checksum_setup generally
 available
Date: Tue, 14 Jan 2014 14:24:50 -0800 (PST)
Message-ID: <20140114.142450.1533356315215529641.davem@davemloft.net>
References: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbaANWYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 17:24:53 -0500
In-Reply-To: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Thu, 9 Jan 2014 10:02:45 +0000

> Both xen-netfront and xen-netback need to be able to set up the partial
> checksum offset of an skb and may also need to recalculate the pseudo-
> header checksum in the process. This functionality is currently private
> and duplicated between the two drivers.
> 
> Patch #1 of this series moves the implementation into the core network code
> as there is nothing xen-specific about it and it is potentially useful to
> any network driver.
> Patch #2 removes the private implementation from netback.
> Patch #3 removes the private implementation from netfront.
> 
> v2:
> - Put skb_checksum_setup in skbuff.c rather than dev.c
> - remove inline

Series applied, thanks.
