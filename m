From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp_notify: unconditionally send gratuitous ARP for
 NETDEV_NOTIFY_PEERS.
Date: Tue, 15 Feb 2011 10:51:14 -0800 (PST)
Message-ID: <20110215.105114.226760606.davem@davemloft.net>
References: <1297446256-23917-1-git-send-email-ian.campbell@citrix.com>
	<20110214.174654.115944453.davem@davemloft.net>
	<1297761225.21980.3663.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46087
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932070Ab1BOSui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 13:50:38 -0500
In-Reply-To: <1297761225.21980.3663.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Tue, 15 Feb 2011 09:13:45 +0000

> On Tue, 2011-02-15 at 01:46 +0000, David Miller wrote:
>> From: Ian Campbell <ian.campbell@citrix.com>
>> Date: Fri, 11 Feb 2011 17:44:16 +0000
>> 
>> > NETDEV_NOTIFY_PEER is an explicit request by the driver to send a link
>> > notification while NETDEV_UP/NETDEV_CHANGEADDR generate link
>> > notifications as a sort of side effect.
 ...
> I nearly forgot -- the NETDEV_NOTIFY_PEER stuff was tagged for
> stable/longterm backport (it appeared in 2.6.32.19 or so). I think this
> change should likewise go back, what do you think?

Sure, I've queued it up for -stable.
