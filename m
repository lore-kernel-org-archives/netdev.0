From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Fri, 03 Sep 2010 14:46:58 -0700 (PDT)
Message-ID: <20100903.144658.149830788.davem@davemloft.net>
References: <20100826170646.GB27157@sgi.com>
	<20100826.122407.260097270.davem@davemloft.net>
	<20100903203044.GN2464@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754075Ab0ICVql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 17:46:41 -0400
In-Reply-To: <20100903203044.GN2464@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Kepner <akepner@sgi.com>
Date: Fri, 3 Sep 2010 13:30:44 -0700

> I have that running on a (very small) system and it seems to 
> work OK. Will send out the patch in just a minute.

Failure vs. non-failure of allocation of a kernel managed physical
resource can't be determined by a userland process which may or may
not be running.

In fact, if I build all of my drivers built-in and use NFS root which
will activate and bring up network devices, userland won't even be
present when the interrupts are requested.

No, you really can't do it this way, IRQ allocation management has to
be in the kernel.
