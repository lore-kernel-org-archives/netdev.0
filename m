From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: igmp: Reduce Unsolicited report interval to 1s when using IGMPv3
Date: Mon, 29 Jul 2013 16:56:03 +0200
Message-ID: <20130729145603.GE2490@order.stressinduktion.org>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com> <1374754445-5608-1-git-send-email-william.manley@youview.com> <20130726163239.GE3890@order.stressinduktion.org> <20130726163913.GG3890@order.stressinduktion.org> <51F67E88.6030006@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:46371 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757058Ab3G2O4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 10:56:05 -0400
Content-Disposition: inline
In-Reply-To: <51F67E88.6030006@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 29, 2013 at 03:39:04PM +0100, William Manley wrote:
> I'll have a look, but I have to admit my ignorance on how multicast 
> works with IPv6 and I may have difficulty setting up a test environment.
> 
> It seems that IGMP has been replaced with "Multicast Listener Discovery" 
> on top of ICMPv6 and much like IGMP there is more than one version:
> 
> 1. RFC2710 - MLD - Unsolicited Report Interval = 10s
> 2. RFC3810 - MLDv2 - Unsolicited Report Interval = 1s

Correct.

> There also seems to be a /proc/sys/net/ipv6/conf/all/force_mld_version. 
>  Ok, so maybe it's not so difficult.  I'll see if I can come up with 
> some additional patches but I'd prefer to keep them separate from the 
> IPv4 ones which I hope are now good-to-go.

Of course, separate patches for ipv6 are favorable. The code is actually
pretty similar to IPv4. Let me know if you need help.

I'll review your IPv4 patches now.

Thanks,

  Hannes
