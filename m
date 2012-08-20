From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve
 fragmentation handling
Date: Mon, 20 Aug 2012 15:13:05 +0200
Message-ID: <1345468385.3069.251.camel@localhost>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
	   <1344542943-11588-6-git-send-email-kaber@trash.net>
	  <1345190795.3069.228.camel@localhost>
	 <Pine.GSO.4.63.1208181423050.17600@stinky-local.trash.net>
	 <1345405069.3069.241.camel@localhost>
	 <Pine.GSO.4.63.1208192141570.3016@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845Ab2HTNNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 09:13:09 -0400
In-Reply-To: <Pine.GSO.4.63.1208192141570.3016@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-08-19 at 21:44 +0200, Patrick McHardy wrote:

> Could you send me your patch so I get a better picture of what you're 
> doing exactly?

Okay, just posted the patchset.

Specifically look at patch:
 [PATCH 3/3] ipvs: Complete IPv6 fragment handling for IPVS

Where I use the hook to copy the fw mark from the reasm SKB packet to
the SKB fragments. (Perhaps, this could be done else were in the
netfilter framework).

--Jesper Brouer
