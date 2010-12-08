From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] ipv6: fix nl group when advertising a new link
Date: Wed, 8 Dec 2010 05:04:54 -0500
Message-ID: <20101208100454.GA7638@canuck.infradead.org>
References: <4CFF5217.6010601@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:46120 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab0LHKE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 05:04:56 -0500
Content-Disposition: inline
In-Reply-To: <4CFF5217.6010601@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 08, 2010 at 10:38:31AM +0100, Nicolas Dichtel wrote:
> >From d2ed52e7fcb639470c89045f7b0ce31eb681896a Mon Sep 17 00:00:00 2001
> From: Wang Xuefu <xuefu.wang@6wind.com>
> Date: Wed, 8 Dec 2010 10:24:48 +0100
> Subject: [PATCH] ipv6: fix nl group when advertising a new link
> 
> New idev are advertised with NL group RTNLGRP_IPV6_IFADDR, but
> should use RTNLGRP_IPV6_IFINFO.
> Bug was introduced by commit 8d7a76c9.
> 
> Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Thomas Graf <tgraf@infradead.org>
