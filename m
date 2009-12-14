From: David Miller <davem@davemloft.net>
Subject: Re: RFC: ethtool: add device-specific feature support in a generic
 fashion
Date: Sun, 13 Dec 2009 20:19:57 -0800 (PST)
Message-ID: <20091213.201957.232755179.davem@davemloft.net>
References: <1260671599.2142.79.camel@localhost>
	<4B246B46.1010103@candelatech.com>
	<1260688164.2142.84.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, mchan@broadcom.com,
	bhutchings@solarflare.com, linville@tuxdriver.com,
	shemminger@linux-foundation.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753430AbZLNETz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 23:19:55 -0500
In-Reply-To: <1260688164.2142.84.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Sat, 12 Dec 2009 23:09:24 -0800

> Excellent points.  Thanks Ben!

See ethtool_gstrings please.

There is no reason to put a "char *" in any of your interfaces, just
as we don't need to in the existing ethtool stats stuff.

And you can put the number of knobs available in struct
ethtool_drvinfo right before n_priv_flags where we have a reserved
area just for adding things like this.

You are specifying way too much new stuff in your datastructures,
unnecessary duplicating existing structures and facilities.

I pointed you at the ethtool private stats stuff because you
can reuse %85 of it's implementation for your purposes :-)
