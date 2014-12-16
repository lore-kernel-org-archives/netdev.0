From: Simon Horman <horms@verge.net.au>
Subject: Re: errors in alignment changes..
Date: Tue, 16 Dec 2014 14:33:32 +0900
Message-ID: <20141216053332.GA12455@verge.net.au>
References: <20141210.155203.1136471667049608187.davem@davemloft.net>
 <5488C447.5080906@cogentembedded.com>
 <20141210.204215.46146677361631214.davem@davemloft.net>
 <20141212043010.GC17790@verge.net.au>
 <548AD8D0.4040207@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	mitsuhiro.kimura.kc@renesas.com, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36211 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaLPFdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 00:33:35 -0500
Content-Disposition: inline
In-Reply-To: <548AD8D0.4040207@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 03:00:16PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/12/2014 7:30 AM, Simon Horman wrote:
> 
> >>From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> >>Date: Thu, 11 Dec 2014 01:08:07 +0300
> 
> >>>    I guess we can just do:
> 
> >>>		rxdesc->addr = dma_map_single(...);
> 
> >>Best not to leave a potentially invalid DMA address in a
> >>receive descriptor the chip can potentially fetch and
> >>look at.
> 
> >>That's why I said to put it into a local variable and
> >>check for errors first.
> 
> >Hi Dave,
> 
> >this patch ending up in net is partially my fault.
> 
> >Sergei, do you have time to address David's concerns in relation to this
> >patch?
> 
>    No, I probably don't.
> 
> >If not I would like to suggest reverting it for now.
> 
>    Why? The patch does what it was intended for. Getting rid of
> virt_to_phys() calls is a separate issue, IMO.

Thanks, that is fine by me.
