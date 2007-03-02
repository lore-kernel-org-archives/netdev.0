From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan & net drivers: avoid a 4-order allocation]
Date: Fri, 02 Mar 2007 13:48:02 -0800 (PST)
Message-ID: <20070302.134802.77406133.davem@davemloft.net>
References: <20070301100217.GA10932@localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: da-x@monatomic.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030359AbXCBVsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 16:48:03 -0500
In-Reply-To: <20070301100217.GA10932@localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Aloni <da-x@monatomic.org>
Date: Thu, 1 Mar 2007 12:02:17 +0200

> This patch splits the vlan_group struct into a multi-allocated struct. On
> x86_64, the size of the original struct is a little more than 32KB, causing
> a 4-order allocation, which is prune to problems caused by buddy-system 
> external fragmentation conditions.
> 
> I couldn't just use vmalloc() because vfree() cannot be called in the
> softirq context of the RCU callback.
> 
> Signed-off-by: Dan Aloni <da-x@monatomic.org>

No objections, this really needs to be fixed, applied.

Thank you.
