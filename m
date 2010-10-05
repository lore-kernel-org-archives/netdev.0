From: Greg KH <greg@kroah.com>
Subject: Re: [stable-2.6.32 PATCH] igb: rx_fifo_errors counter fix
Date: Tue, 5 Oct 2010 16:19:48 -0700
Message-ID: <20101005231948.GA21504@kroah.com>
References: <20101005230407.24172.84596.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:46870 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758062Ab0JEXV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 19:21:59 -0400
Content-Disposition: inline
In-Reply-To: <20101005230407.24172.84596.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 05, 2010 at 04:04:09PM -0700, Jeff Kirsher wrote:
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
> ---
> 
>  drivers/net/igb/igb_main.c |    5 ++---

Why isn't this needed in Linus's tree?  If it is in Linus's tree, what
is the git commit id?

Is it needed in .35?  Please, more context...

thanks,

greg k-h
