From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: Use actual number of PCI functions (PF
 + VFs) for alias GUID logic
Date: Tue, 25 Mar 2014 20:48:45 -0400 (EDT)
Message-ID: <20140325.204845.517160725772491234.davem@davemloft.net>
References: <1395561043-435-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, matanb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbaCZAsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 20:48:46 -0400
In-Reply-To: <1395561043-435-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 23 Mar 2014 09:50:43 +0200

> From: Matan Barak <matanb@mellanox.com>
> 
> The code which is dealing with SRIOV alias GUIDs in the mlx4 IB driver has some
> logic which operated according to the maximal possible active functions (PF + VFs).
> 
> After the single port VFs code integration this resulted in a flow of false-positive
> warnings going to the kernel log after the PF driver started the alias GUID work. 
> 
> Fix it by referring to the actual number of functions.
> 
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
