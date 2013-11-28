From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch v3] IPv6: Fixed support for blackhole and prohibit routes
Date: Thu, 28 Nov 2013 19:49:47 +0100
Message-ID: <20131128184947.GB24171@order.stressinduktion.org>
References: <1385629923-22920-1-git-send-email-kamala@aristanetwors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Kamala R <kamala@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44791 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab3K1Stt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 13:49:49 -0500
Content-Disposition: inline
In-Reply-To: <1385629923-22920-1-git-send-email-kamala@aristanetwors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 02:42:03PM +0530, Kamala R wrote:
> From: Kamala R <kamala@aristanetworks.com>
> 
> The behaviour of blackhole and prohibit routes has been corrected by setting
> the input and output pointers of the dst variable appropriately. For
> blackhole routes, they are set to dst_discard and to ip6_pkt_discard and
> ip6_pkt_discard_out respectively for prohibit routes.
> 
> Signed-off-by: Kamala R <kamala@aristanetworks.com>

Thanks for changing this once again!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
