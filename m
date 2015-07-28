From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 28 Jul 2015 09:20:52 +0200
Message-ID: <20150728072052.GA12945@unicorn.suse.cz>
References: <55B6E8AC.4060600@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>
To: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46032 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775AbbG1HUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 03:20:55 -0400
Content-Disposition: inline
In-Reply-To: <55B6E8AC.4060600@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2015 at 02:27:57AM +0000, Richard Laing wrote:
> From: Richard Laing <richard.laing@alliedtelesis.co.nz>
> 
> Enable flow-based ECMP.
> 
> Currently if equal-cost multipath is enabled the kernel chooses between
> equal cost paths for each matching packet, essentially packets are
> round-robined between the routes. This means that packets from a single
> flow can traverse different routes. If one of the routes experiences
> congestion this can result in delayed or out of order packets arriving
> at the destination.
> 
> This patch allows packets to be routed based on their
> flow - packets in the same flow will always use the same route. This
> prevents out of order packets. There are other issues with round-robin
> based ECMP routing related to variable path MTU handling and debugging.
> See RFC2991 for more details on the problems associated with packet
> based ECMP routing.
> 
> This patch relies on the skb hash value to select between routes. The
> selection uses a hash-threshold algorithm (see RFC2992).
> 
> Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>

The patch looks corrupted (long lines split, tabs converted to (four?)
spaces etc.

                                                        Michal Kubecek
