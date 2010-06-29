From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35] bonding: prevent netpoll over bonded interfaces
Date: Mon, 28 Jun 2010 23:54:44 -0700 (PDT)
Message-ID: <20100628.235444.241924787.davem@davemloft.net>
References: <20100625195044.GQ7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, fubar@us.ibm.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48600
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752428Ab0F2Gyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:54:31 -0400
In-Reply-To: <20100625195044.GQ7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Fri, 25 Jun 2010 15:50:44 -0400

> 
> Support for netpoll over bonded interfaces was added here:
> 
> 	commit f6dc31a85cd46a959bdd987adad14c3b645e03c1
> 	Author: WANG Cong <amwang@redhat.com>
> 	Date:   Thu May 6 00:48:51 2010 -0700
> 
> 	    bonding: make bonding support netpoll
> 
> but it is bad enough that we should probably just disable netpoll over
> bonding until some of the locking logic in the bonding driver is changed
> or converted completely to RCU.  Simple actions like changing the active
> slave in active-backup mode will hang the box if a high enough printk
> debugging level is enabled.
> 
> Keeping the old code around will be good for anyone that wants to work
> on it (and for after the RCU conversion), so I propose this small patch
> rather than ripping it all out.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied, thanks a lot Andy.
