From: David Miller <davem@davemloft.net>
Subject: Re: How do queue-less virtual devices wake higher level senders?
Date: Mon, 01 Oct 2007 20:44:29 -0700 (PDT)
Message-ID: <20071001.204429.116377914.davem@davemloft.net>
References: <47018772.4060803@candelatech.com>
	<20071001.170410.40806513.davem@davemloft.net>
	<47018FBA.4030700@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33964
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751757AbXJBDo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 23:44:29 -0400
In-Reply-To: <47018FBA.4030700@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 01 Oct 2007 17:24:26 -0700

> David Miller wrote:
> > From: Ben Greear <greearb@candelatech.com>
> > Date: Mon, 01 Oct 2007 16:49:06 -0700
> > 
> >> For 'real' hardware, it seems that the netif_stop_queue and
> >> netif_wake_queue methods handle stopping and waking the
> >> higher level senders, but for virtual devices with no
> >> queues, how does this work?
> > 
> > They don't queue, there is nothing to stop or wakeup.
> 
> Ok, so if I have a UDP socket bound to an interface that has
> no queue, and yet I see the send portion of the queue being
> full in netstat, what does this mean?

The physical device sitting behind the virtual one is where
queue stop and wakeup operations might be occuring.
