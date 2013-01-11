From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Problem with IPv6 Route Cache
Date: Fri, 11 Jan 2013 16:06:51 +0100
Message-ID: <20130111150651.GA25485@order.stressinduktion.org>
References: <20130111185126.56cababe@natsu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Roman Mamedov <rm@romanrm.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49540 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373Ab3AKPGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 10:06:52 -0500
Content-Disposition: inline
In-Reply-To: <20130111185126.56cababe@natsu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 06:51:26PM +0600, Roman Mamedov wrote:
> This is on kernel version 3.7.1 inside a Xen VPS (if this matters).
> 
> Can anyone advice how to deal with this problem?
> Can I disable/remove the IPv6 route cache?
> I know the IPv4 route cache was recently removed from the kernel.

There is no IPv6 route cache as there was one for IPv4. The routes are
"merely" cloned directly into the fib tree.
