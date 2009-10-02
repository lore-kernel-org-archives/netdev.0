From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: export device speed and duplex via sysfs
Date: Fri, 02 Oct 2009 19:19:14 +0100
Message-ID: <1254507554.8795.12.camel@achroite>
References: <20091002180742.GH4436@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41715 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758032AbZJBSTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:19:12 -0400
In-Reply-To: <20091002180742.GH4436@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-02 at 14:07 -0400, Andy Gospodarek wrote:
> This exports the link-speed (in Mbps) and duplex of an interface via
> sysfs.  This eliminates the need to use ethtool just to check the
> link-speed.  Not requiring 'ethtool' and not relying on the SIOCETHTOOL
> ioctl should be helpful in an embedded environment where space is at a
> premium as well.

It's trivial to write an ethtool-lite that does this.  That might be
worth adding to busybox.

> NOTE: This patch also intentionally allows non-root users to check the link
> speed and duplex -- something not possible with ethtool.
[...]

Assuming this is desirable (I'm not sure), wouldn't it would make more
sense to move the permissions check for SIOCETHTOOL so that get_settings
is non-privileged?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

