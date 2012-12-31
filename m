From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] tcp: split tcp_ecn sysctl knob to distinguish between IPv4 and IPv6
Date: Tue, 1 Jan 2013 00:58:02 +0100
Message-ID: <20121231235802.GD11700@order.stressinduktion.org>
References: <20121231173532.GA11700@order.stressinduktion.org> <20121231140538.6e55c82d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57916 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab2LaX6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 18:58:04 -0500
Content-Disposition: inline
In-Reply-To: <20121231140538.6e55c82d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2012 at 02:05:38PM -0800, Stephen Hemminger wrote:
> On Mon, 31 Dec 2012 18:35:33 +0100
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > ECN could be more reliable when used with IPv6 (I don't have proofs). For
> > people who want to try ECN with IPv6 but still have problems connecting
> > to destinations because of broken IPv4 routers this switch allows one
> > to enable ECN just for IPv6.
> > 
> > Perhaps ECN could be enabled by default in future.
> > 
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Any new or modified sysctl should be documented in:
>   Documentation/networking/ip-sysctl.txt

Ack. I'll wait a bit for further feedback and will submit a -v2 with updated
documentation.
