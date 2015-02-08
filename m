From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: addrconf: add missing validate_link_af
 handler
Date: Sat, 07 Feb 2015 22:13:56 -0800 (PST)
Message-ID: <20150207.221356.878303677603562311.davem@davemloft.net>
References: <0f0921b794041725c882546a614defde18fba7ea.1423143235.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbBHGN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:13:57 -0500
In-Reply-To: <0f0921b794041725c882546a614defde18fba7ea.1423143235.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  5 Feb 2015 14:39:11 +0100

> We still need a validate_link_af() handler with an appropriate nla policy,
> similarly as we have in IPv4 case, otherwise size validations are not being
> done properly in that case.
> 
> Fixes: f53adae4eae5 ("net: ipv6: add tokenized interface identifier support")
> Fixes: bc91b0f07ada ("ipv6: addrconf: implement address generation modes")
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

A nice, old, bug.

Applied and queued up for -stable, thanks Daniel.
