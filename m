From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Tue, 5 May 2009 11:47:09 -0700
Message-ID: <9929d2390905051147y71f34e4bu9f63edc1e5a253a2@mail.gmail.com>
References: <1241435206.8115.104.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:18298 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202AbZEESrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 14:47:09 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2734187ywb.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2009 11:47:09 -0700 (PDT)
In-Reply-To: <1241435206.8115.104.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 4, 2009 at 4:06 AM, Jesper Dangaard Brouer <hawk@comx.dk> wrote:
>
> Hardware RX fifo overruns for the 82576 is stored in the
> RNBC (Receive No Buffers Count) register.
>
> I choose the store the RNBC value in net_stats.rx_fifo_errors.
>
> Saving the stats in dev->net_stats makes it visible via
> /proc/net/dev as "fifo", and thus viewable to ifconfig
> as "overruns" and 'netstat -i' as "RX-OVR".
>
> The Receive No Buffers Count (RNBC) can already be queried by
> ethtool -S as "rx_no_buffer_count".
>
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
>

NAK.  RNBC is not a counter for buffer overruns, and so should not be
counted as such.

-- 
Cheers,
Jeff
