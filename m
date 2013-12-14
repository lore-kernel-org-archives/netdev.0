From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Sat, 14 Dec 2013 10:22:04 +0100
Message-ID: <20131214092204.GC23563@order.stressinduktion.org>
References: <1386843347-2725-1-git-send-email-yazzep@gmail.com> <1386956028-3463-1-git-send-email-yazzep@gmail.com> <20131214091917.GB23563@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: yazzep@gmail.com, netdev@vger.kernel.org,
	Yasushi Asano <yasushi.asano@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54960 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab3LNJWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 04:22:05 -0500
Content-Disposition: inline
In-Reply-To: <20131214091917.GB23563@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 14, 2013 at 10:19:17AM +0100, Hannes Frederic Sowa wrote:
> IMHO, the changes need to be made in addrconf_verify so that the route does
 
								   ^^^^
I actually meant address, sorry. The route must stay valid of course.

> get marked as deprecated. Please check the places where we mark an interface
> address as deprecated.
