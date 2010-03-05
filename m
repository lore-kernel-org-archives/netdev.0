From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix netdev_printk null dereference
Date: Fri, 05 Mar 2010 06:39:09 -0800 (PST)
Message-ID: <20100305.063909.26489418.davem@davemloft.net>
References: <1267793225-426-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35957
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752516Ab0CEOiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 09:38:50 -0500
In-Reply-To: <1267793225-426-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Fri,  5 Mar 2010 12:47:05 +0000

> This patch fixes a reproducible null dereference in smsc95xx (and I
> suspect others) when the device is removed during a control register
> access.  This can be reproduced by rapidly plugging and unplugging
> the device during its initialisation.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

The parent shouldn't become NULL until the device is totally quiesced
and is no longer accesses.

Maybe you can instead fix the smsc95xx driver to abide by this rule
instead of adding a conditional check to thousands of other drivers in
the tree that do not need this?

I really have no intention of adding your change, please fix this
properly, thanks.
