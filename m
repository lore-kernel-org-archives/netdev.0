From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NETFILTER: per-netns FILTER/MANGLE/RAW tables for real
Date: Thu, 20 Mar 2008 16:29:42 +0100
Message-ID: <47E282E6.4070907@trash.net>
References: <20080303160659.GB19059@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep32-int.chello.at ([62.179.121.50]:42717 "EHLO
	viefep32-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755885AbYCTP3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 11:29:51 -0400
In-Reply-To: <20080303160659.GB19059@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Commit 9335f047fe61587ec82ff12fbb1220bcfdd32006 aka
> "[NETFILTER]: ip_tables: per-netns FILTER, MANGLE, RAW"
> added per-netns _view_ of iptables rules. They were shown to user, but
> ignored by filtering code. Now that it's possible to at least ping loopback,
> per-netns tables can affect filtering decisions.
> 
> netns is taken in case of
> 	PRE_ROUTING, LOCAL_IN -- from in device,
> 	POST_ROUTING, LOCAL_OUT -- from out device,
> 	FORWARD -- from in device which should be equal to out device's netns.
> 		   This code is relatively new, so BUG_ON was plugged.
> 
> Wrappers were added to a) keep code the same from CONFIG_NET_NS=n users
> (overwhelming majority), b) consolidate code in one place -- similar
> changes will be done in ipv6 and arp netfilter code.

Applied, thanks.
