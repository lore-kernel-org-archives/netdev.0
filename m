From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NEIGH]: Fix race between neighbor lookup and table's
 hash_rnd update.
Date: Sat, 23 Feb 2008 19:57:23 -0800 (PST)
Message-ID: <20080223.195723.218310011.davem@davemloft.net>
References: <47BE97BF.6020600@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42337
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752067AbYBXD4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 22:56:42 -0500
In-Reply-To: <47BE97BF.6020600@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 22 Feb 2008 12:37:03 +0300

> The neigh_hash_grow() may update the tbl->hash_rnd value, which 
> is used in all tbl->hash callbacks to calculate the hashval.
> 
> Two lookup routines may race with this, since they call the 
> ->hash callback without the tbl->lock held. Since the hash_rnd
> is changed with this lock write-locked moving the calls to ->hash
> under this lock read-locked closes this gap.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
