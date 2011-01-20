From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 26632] New: rtl8169 slow to come up and not
 allowing telnetd-ssl negotiation
Date: Wed, 19 Jan 2011 16:27:48 -0800 (PST)
Message-ID: <20110119.162748.212393653.davem@davemloft.net>
References: <bug-26632-10286@https.bugzilla.kernel.org/>
	<20110119145904.d750d49d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@medozas.de,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, arthur.marsh@internode.on.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753331Ab1ATA1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 19:27:14 -0500
In-Reply-To: <20110119145904.d750d49d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 19 Jan 2011 14:59:04 -0800

> This regression was bisected to
> 
> 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf is the first bad commit
> commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf
> Author: Jan Engelhardt <jengelh@medozas.de>
> Date:   Fri Jan 7 03:15:05 2011 +0000
> 
>     netlink: test for all flags of the NLM_F_DUMP composite

Which is being reverted.
