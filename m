From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [NET] random : secure_tcp_sequence_number should not
	assume CONFIG_KTIME_SCALAR
Date: Wed, 14 Nov 2007 11:49:19 -0800
Message-ID: <20071114194919.GC10318@kroah.com>
References: <47398ADD.2030509@cosmosbay.com> <20071113.035019.268404275.davem@davemloft.net> <4739A97F.60206@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, stable@kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58272 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110AbXKNTwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 14:52:01 -0500
Content-Disposition: inline
In-Reply-To: <4739A97F.60206@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 02:41:19PM +0100, Eric Dumazet wrote:
> I discovered one other incorrect use of .tv64 (coming from me, I must 
> confess)
>
> I guess this patch is  needed for 2.6.24 and stable (2.6.22 & 2.6.23)
>
> Thank you

Thanks for sending this to stable@, but David does a great job of
forwarding these to us, so I'll wait for him to relay it to us before
taking it into our tree.

thanks,

greg k-h
