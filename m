From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Fix resource use after free
Date: Tue, 13 Nov 2007 21:16:43 -0800 (PST)
Message-ID: <20071113.211643.94988047.davem@davemloft.net>
References: <1194920136881-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, monis@voltaire.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750927AbXKNFQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:16:43 -0500
In-Reply-To: <1194920136881-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 12 Nov 2007 18:15:36 -0800

> 	Fix bond_destroy and bond_free_all to not reference the
> struct net_device after calling unregister_netdevice.
> 
> 	Bug and offending change reported by Moni Shoua <monis@voltaire.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied to net-2.6, thanks Jay.
