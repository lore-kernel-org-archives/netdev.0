From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] move dma_head/dma_maps out of skb_shared_info and into
 sk_buff
Date: Fri, 06 Nov 2009 01:58:49 -0800 (PST)
Message-ID: <20091106.015849.135245242.davem@davemloft.net>
References: <4AF373C9.7040700@intel.com>
	<20091105.174024.105269738.davem@davemloft.net>
	<1257476452.14523.10.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41121
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752173AbZKFJ6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 04:58:24 -0500
In-Reply-To: <1257476452.14523.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 05 Nov 2009 19:00:52 -0800

> Would there be any complaint if I were to submit a patch that removed
> skb_dma_map/unmap?

I'm still thinking about exactly what to do here.  In the meantime
feel free to toss this skb_dma_{map,unmap}() removal patch together.

Thanks.
