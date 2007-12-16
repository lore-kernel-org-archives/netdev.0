From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 4/7] Store the net pointer on devinet's ctl
 tables
Date: Sun, 16 Dec 2007 13:31:23 -0800 (PST)
Message-ID: <20071216.133123.195336012.davem@davemloft.net>
References: <475ECC69.1040809@openvz.org>
	<475ECEB3.7060502@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48835
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759294AbXLPVbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:31:31 -0500
In-Reply-To: <475ECEB3.7060502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Dec 2007 20:53:55 +0300

> Some handers and strategies of devinet sysctl tables need
> to know the net to propagate the ctl change to all the
> net devices.
> 
> I use the (currently unused) extra2 pointer on the tables
> to get it.
> 
> Holding the reference on the struct net is not possible,
> because otherwise we'll get a net->ctl_table->net circular
> dependency. But since the ctl tables are unregistered during 
> the net destruction, this is safe to get it w/o additional 
> protection.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
