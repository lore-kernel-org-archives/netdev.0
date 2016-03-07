From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmveth: check return of skb_linearize in
 ibmveth_start_xmit
Date: Mon, 07 Mar 2016 14:40:00 -0500 (EST)
Message-ID: <20160307.144000.876768813657740804.davem@davemloft.net>
References: <1457040156-3377-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577AbcCGTkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:40:03 -0500
In-Reply-To: <1457040156-3377-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Thu,  3 Mar 2016 15:22:36 -0600

> If skb_linearize fails, the driver should drop the packet
> instead of trying to copy it into the bounce buffer.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied, thank you.
