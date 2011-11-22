From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next] virtio_net: return already tracked tx_fifo_errors via virtnet_getstats()
Date: Tue, 22 Nov 2011 11:26:34 +1030
Message-ID: <87aa7px9dp.fsf@rustcorp.com.au>
References: <20111121192817.F2CAE290041F@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rick Jones <raj@tardy.cup.hp.com>, netdev@vger.kernel.org,
	mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51789 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753617Ab1KVA75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 19:59:57 -0500
In-Reply-To: <20111121192817.F2CAE290041F@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Nov 2011 11:28:17 -0800 (PST), raj@tardy.cup.hp.com (Rick Jones) wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> Tx_fifo_errors are tracked in start_xmit_ for virtio_net, but not
> reported in the tallies returned by virtnet_stats().  Return them
> as the rx "sub-stats" rx_length_errors and rx_frame_errors are.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Cheers,
Rusty.
