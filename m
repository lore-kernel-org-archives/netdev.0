From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 09:52:00 +0000
Message-ID: <20090217095200.GA5538@ff.dom.local>
References: <20090216232016.GA4803@ami.dom.local> <499A7D7D.1090607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karl Hiramoto <karl@hiramoto.org>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:29180 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbZBQJwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 04:52:08 -0500
Content-Disposition: inline
In-Reply-To: <499A7D7D.1090607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2009 at 10:03:57AM +0100, Patrick McHardy wrote:
...
> The first patch looks fine. As for the second one, I would like
> to understand why we're seing these packets. The VLAN driver uses
> the original headroom plus the space it needs itself, which suggests
> that the underlying driver specifies an incorrect headroom.
> The driver doesn't appear to be part of the mainline kernel though.

On the other hand, if Karl added his patch it seems this change of
NET_SKB_PAD isn't enough, and if omitting skb_cow_head() works, then
the headroom isn't the main problem?

Jarek P.
