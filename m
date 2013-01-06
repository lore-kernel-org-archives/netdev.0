From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] tcp: split tcp_ecn sysctl knob to distinguish between IPv4 and IPv6
Date: Sun, 6 Jan 2013 02:31:17 +0100
Message-ID: <20130106013117.GC28545@order.stressinduktion.org>
References: <20130103000009.GG4464@order.stressinduktion.org> <20130103122844.GH4464@order.stressinduktion.org> <20130103.045350.1322196416782379673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38416 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754618Ab3AFBbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 20:31:18 -0500
Content-Disposition: inline
In-Reply-To: <20130103.045350.1322196416782379673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2013 at 04:53:50AM -0800, David Miller wrote:
> > On Thu, Jan 03, 2013 at 01:00:09AM +0100, Hannes Frederic Sowa wrote:
> >> ECN could be more reliable when used with IPv6 (I don't have proofs). For
> >> people who want to try ECN with IPv6 but still have problems connecting
> >> to destinations because of broken IPv4 routers this switch allows one
> >> to enable ECN just for IPv6.
> >> 
> >> Perhaps ECN could be enabled by default in future.
> >> 
> >> No code changes since initial submission, just added documentation.
> > 
> > May I ask what lead to the rejection of the patch?
> 
> I don't see any value in splitting up ipv4 and ipv6.
> 
> I think we should turn the existing knob on unliaterally
> by default.  That would be a much better patch.

I wonder if we really should go down this route to turn on ecn by
default or if I should try to come up with a patch which marks non
working ecn paths in the destination cache and suppress ecn for those
connections. Any advice?
