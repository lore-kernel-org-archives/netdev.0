From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] l2tp: fix ancillary data handling in ipv6 recv
Date: Thu, 31 Jan 2013 13:53:23 -0500 (EST)
Message-ID: <20130131.135323.1045623088532919420.davem@davemloft.net>
References: <1359630146-8305-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab3AaSx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 13:53:26 -0500
In-Reply-To: <1359630146-8305-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Thu, 31 Jan 2013 11:02:23 +0000

> Resubmitting to fix up whitespace issues.
> 
> This patchset:
> 
>         * Renames the ipv6-specific datagram_send_ctl and datagram_recv_ctl
>           functions as ip6_datagram_*.  Since datagram_send_ctl is publicly
>           exported it should be named such that it's clearly IPv6-specific.
> 
>         * Exports ip6_datagram_recv_ctl, so that modules may use it in their
>           receive paths.
> 
>         * Changes l2tp_ip6 from using the IPv4-specific ip_cmsg_recv to use the
>           IPv6 version ip6_datagram_recv_ctl.

Series applied, thanks a lot Tom.
