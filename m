From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tun: TUNGETIFF interface to query name and flags
Date: Fri, 15 Aug 2008 15:10:09 -0700 (PDT)
Message-ID: <20080815.151009.157459097.davem@davemloft.net>
References: <1218637816.29159.31.camel@muff>
	<200808141158.57879.rusty@rustcorp.com.au>
	<48A5C433.7030002@qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.osdl.org
To: maxk@qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48025
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753374AbYHOWKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 18:10:10 -0400
In-Reply-To: <48A5C433.7030002@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Krasnyansky <maxk@qualcomm.com>
Date: Fri, 15 Aug 2008 11:00:19 -0700

> Rusty Russell wrote:
> > On Thursday 14 August 2008 00:30:16 Mark McLoughlin wrote:
> >> A very simple approach is attached; I did consider doing a TUNGETFLAGS
> >> that would return tun->flags, but I think it's nicer to have a companion
> >> to TUNGETIFF since it also allows one to query the interface name from
> >> the file descriptor.
> > 
> > This seems really sensible to me.
> > 
> > If Max acks it, I'd say Dave should merge it.
> 
> Makes perfect sense to me.
> Definitely Ack. It has zero impact on existing user and I'd be ok if this goes
>  in during .27-rc series.

I've applied Mark's patch, thanks.
