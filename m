From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC PATCH 4/6] firewire net: Export peerinfo handlers.
Date: Sat, 12 Jan 2013 16:01:28 +0100
Message-ID: <20130112160128.3872495c@stein>
References: <50F1716A.90401@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephan Gatzka <stephan.gatzka@gmail.com>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:60010 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3ALPBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 10:01:48 -0500
In-Reply-To: <50F1716A.90401@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 YOSHIFUJI Hideaki wrote:
[...]
> --- a/drivers/firewire/net.c
> +++ b/drivers/firewire/net.c
[...]
> +EXPORT_SYMBOL(fwnet_update_peerinfo);
[...]
> +EXPORT_SYMBOL(fwnet_fill_peerinfo);

I disagree.  drivers/firewire/net.c is no place for EXPORTs.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
