From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 2/3] net: igmp: Don't flush routing cache when force_igmp_version is modified
Date: Wed, 7 Aug 2013 02:45:47 +0200
Message-ID: <20130807004547.GF16410@order.stressinduktion.org>
References: <20130731063442.GA10498@order.stressinduktion.org> <1375812195-6575-1-git-send-email-william.manley@youview.com> <1375812195-6575-3-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35851 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab3HGAps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 20:45:48 -0400
Content-Disposition: inline
In-Reply-To: <1375812195-6575-3-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 07:03:14PM +0100, William Manley wrote:
> The procfs knob /proc/sys/net/ipv4/conf/*/force_igmp_version allows the
> IGMP protocol version to use to be explicitly set.  As a side effect this
> caused the routing cache to be flushed as it was declared as a
> DEVINET_SYSCTL_FLUSHING_ENTRY.  Flushing is unnecessary and this patch
> makes it so flushing does not occur.
> 
> Requested by Hannes Frederic Sowa as he was reviewing other patches
> adding procfs entries.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: William Manley <william.manley@youview.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
