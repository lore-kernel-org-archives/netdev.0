From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next] IPv6 address labels per namespace - v2
Date: Thu, 29 May 2008 16:39:09 +0900 (JST)
Message-ID: <20080529.163909.07573021.yoshfuji@linux-ipv6.org>
References: <20080528125114.372886409@theryb.frec.bull.fr>
	<20080528125137.228283589@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53548 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbYE2Hij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 03:38:39 -0400
In-Reply-To: <20080528125137.228283589@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080528125137.228283589@theryb.frec.bull.fr> (at Wed, 28 May 2008 14:51:24 +0200), Benjamin Thery <benjamin.thery@bull.net> says:

> This pacth makes IPv6 address labels per network namespace.
> It keeps the global label tables, ip6addrlbl_table, but 
> adds a 'net' member to each ip6addrlbl_entry.
> This new member is taken into account when matching labels.
> 
> Changelog
> =========
> * v1: Initial version 
> * v2:
>   * Minize the penalty when network namespaces are not configured:
>       *  the 'net' member is added only if CONFIG_NET_NS is 
>          defined. This saves space when network namespaces are not 
>          configured.
>       * 'net' value is retrieved with the inlined function 
>          ip6addrlbl_net() that always return &init_net when 
>          CONFIG_NET_NS is not defined.
>   * 'net' member in ip6addrlbl_entry renamed to the less generic 
>     'lbl_net' name (helps code search).
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

I'm going to apply this.  Thank you.

--yoshfuji
