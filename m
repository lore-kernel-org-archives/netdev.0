From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: Route exceptions for IPv6 routes?
Date: Wed, 15 Jan 2014 14:04:54 +0100
Message-ID: <20140115130454.GE19945@order.stressinduktion.org>
References: <20140115115115.GD19945@order.stressinduktion.org> <trinity-6d5496d3-c58c-4b56-a0a8-777473467042-1389788725698@3capp-gmx-bs13>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39167 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaAONEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 08:04:55 -0500
Content-Disposition: inline
In-Reply-To: <trinity-6d5496d3-c58c-4b56-a0a8-777473467042-1389788725698@3capp-gmx-bs13>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Wed, Jan 15, 2014 at 01:25:25PM +0100, Simon Schneider wrote:
> thanks for the answer.
> 
> Sorry, I'm not so familiar with the implementation details.
> 
> What are nh-exceptions?

Nexthop exceptions, they store e.g. pmtu information in IPv4.

> I understand the current IPv6 implementation has some performance drawbacks. Correct?
> 
> I'm especially interested in 
> a) support for path MTUs

They are stored in the RTF_CACHED leafs of the routing table.

> b) IPv6 policy-based routing (can I expect the same results from "ip -6 rule" commands that I get from "ip rule" commands?)

Yes, you can. And they have nearly the same implementation overhead.

Additionally you can add routes which match a specific source and handle them
directly, this is a feature only in IPv6:

E.g. ip -6 route add .... from ... via ...

Greetings,

  Hannes
