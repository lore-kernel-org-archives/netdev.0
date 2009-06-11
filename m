From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] drivers/net/macvlan.c: fix cloning of tagged VLAN
 interfaces
Date: Thu, 11 Jun 2009 02:34:40 -0700 (PDT)
Message-ID: <20090611.023440.230373737.davem@davemloft.net>
References: <200906101955.n5AJt2a2008184@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sg.tweak@gmail.com,
	alan@lxorguk.ukuu.org.uk, rjw@sisk.pl, shemminger@vyatta.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754215AbZFKJeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:34:37 -0400
In-Reply-To: <200906101955.n5AJt2a2008184@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 10 Jun 2009 12:55:02 -0700

> From: <sg.tweak@gmail.com>
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=13348
> 
> akpm: the reporter disappeared, so I typed it in again.
> 
> It is not possible to make clone of tagged VLAN interface to be used as
> mac-based vlan interfave.
 ...
> Macvlan driver always uses standard ethernet header length for all types
> of interface to which it is linked.  This patch fixes this problem.
> 
> Reported-by: <sg.tweak@gmail.com>
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
