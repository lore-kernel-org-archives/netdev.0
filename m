From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 01/11] ixgbe: Do not use DCA to prefetch the entire
 packet into the cache
Date: Tue, 13 Nov 2012 06:13:31 -0800
Message-ID: <1352816011.6185.33.camel@edumazet-glaptop>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1352815405-751-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:49845 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953Ab2KMONe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 09:13:34 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so10713180iea.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 06:13:33 -0800 (PST)
In-Reply-To: <1352815405-751-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 06:03 -0800, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The way the code was previously written it was causing DCA to prefetch the
> entire packet into the cache when it was enabled.  That is excessive as we
> only really need the headers.
> 
> We are now prefetching the headers via software so doing this from DCA would
> be redundant anyway.  So clear the bit that was causing us to prefetch the
> packet data and instead only use DCA for the descriptor rings.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Excellent !

My own ixgbe cards are moving so I cant test this, do you guys have some
numbers to share ?

Thanks
