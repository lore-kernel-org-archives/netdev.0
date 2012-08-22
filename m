From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve fragmentation
 handling
Date: Thu, 23 Aug 2012 00:21:05 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208230020380.5113@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>   
 <1344542943-11588-6-git-send-email-kaber@trash.net>   <1345190795.3069.228.camel@localhost>
  <Pine.GSO.4.63.1208181423050.17600@stinky-local.trash.net>
 <1345405069.3069.241.camel@localhost>  <Pine.GSO.4.63.1208192141570.3016@stinky-local.trash.net>
 <1345468385.3069.251.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63580 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab2HVWVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 18:21:06 -0400
In-Reply-To: <1345468385.3069.251.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Aug 2012, Jesper Dangaard Brouer wrote:

> On Sun, 2012-08-19 at 21:44 +0200, Patrick McHardy wrote:
>
>> Could you send me your patch so I get a better picture of what you're
>> doing exactly?
>
> Okay, just posted the patchset.
>
> Specifically look at patch:
> [PATCH 3/3] ipvs: Complete IPv6 fragment handling for IPVS
>
> Where I use the hook to copy the fw mark from the reasm SKB packet to
> the SKB fragments. (Perhaps, this could be done else were in the
> netfilter framework).

Thanks, I'll have a look at this tommorrow.
