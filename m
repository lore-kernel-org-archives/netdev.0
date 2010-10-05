From: David Miller <davem@davemloft.net>
Subject: Re: [stable-2.6.32 PATCH] igb: rx_fifo_errors counter fix
Date: Tue, 05 Oct 2010 16:14:10 -0700 (PDT)
Message-ID: <20101005.161410.22053881.davem@davemloft.net>
References: <20101005230407.24172.84596.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, stable@kernel.org, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, eric.dumazet@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756284Ab0JEXNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 19:13:49 -0400
In-Reply-To: <20101005230407.24172.84596.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 05 Oct 2010 16:04:09 -0700

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Alexey Vlasov reported insane rx_queue_drop_packet_count
> (rx_fifo_errors) values.
> 
> IGB drivers is doing an accumulation for 82575, instead using a zero
> value for rqdpc_total.
> 
> Reported-by: Alexey Vlasov <renton@renton.name>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: David S. Miller <davem@davemloft.net>
