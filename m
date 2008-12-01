From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: fix /proc/net/ip_mr_cache display
Date: Mon, 1 Dec 2008 09:33:41 -0800
Message-ID: <20081201093341.537bf03d@extreme>
References: <20081201160214.965805516@localhost.localdomain>
	<493415B4.7020600@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	netdev hem <netdev@vger.kernel.org>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46407 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbYLARdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 12:33:43 -0500
In-Reply-To: <493415B4.7020600@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Dec 2008 17:49:56 +0100
Benjamin Thery <benjamin.thery@bull.net> wrote:

> Argh, my patch breaks iproute2 command: ip mroute show
> 
> iproute2 uses sscanf() to read /proc/net/ip_mr_cache and expects 6
> fields to be read. For the unresolved entries my patch only displays
> the first three fields. As a consequence, 'ip mroute show' skips the
> unresolved entries. :(
> 
> So we can
> - either forget this patch and keep displaying garbage information
>    in /proc/net/ip[6]_mr_cache for the unresolved entries. (No one
>    complained before)
> - or may be we can just print '-' or 0 for the fields that have no
>    data associated in the unresolved case.
> 
> Tell me what you prefer.
> 
> Benjamin

/proc file formats are part of the Linux ABI and can't change!
