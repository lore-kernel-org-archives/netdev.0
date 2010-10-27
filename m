From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: account for VLAN when checking packet size
Date: Wed, 27 Oct 2010 08:48:54 -0700 (PDT)
Message-ID: <20101027.084854.71130929.davem@davemloft.net>
References: <20101012171940.GB30613@redhat.com>
	<20101012.104032.71103852.davem@davemloft.net>
	<20101022084052.GA2118@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47806
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760749Ab0J0Psb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 11:48:31 -0400
In-Reply-To: <20101022084052.GA2118@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Fri, 22 Oct 2010 10:41:26 +0200

> Incidently, I believe that this problem will only become more acute
> and complex if support for 802.1ad (Provider Bridges, aka Q-in-Q),
> 802.1ah (Provider Backbone Bridges, aka MAC-in-MAC) or other standards
> which further extend the maximum frame size.

No doubt.

> Dave, you were mentioning to me the other day that the kernel
> already supports some notion of Q-in-Q (though its not 802.1ad).
> Does the current implementation allow for frames > 1504 bytes?

It's only going to hardware offload and allow the extra space
for the outer-most VLAN tag.  Everthing inside of the outer
tag will be handled in software as far as Linux is concerned.

> Is that a complication to the change proposed here?

For now, I don't think so.
