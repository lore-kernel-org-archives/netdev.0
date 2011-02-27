From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 01/10] ethtool: prevent null pointer
 dereference with NTUPLE set but no set_rx_ntuple
Date: Sat, 26 Feb 2011 16:07:47 -0800 (PST)
Message-ID: <20110226.160747.226765885.davem@davemloft.net>
References: <20110225233244.7920.26742.stgit@gitlad.jf.intel.com>
	<1298679675.3555.4.camel@localhost>
	<4D684BED.20805@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750838Ab1B0AHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 19:07:11 -0500
In-Reply-To: <4D684BED.20805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 25 Feb 2011 16:40:13 -0800

> It cannot occur with any of the in-kernel drivers since they all set
> the NETIF_F_NTUPLE flag and have the function defined.  However going
> forward I would like to have the option of using the network flow
> classifier interface instead of the set_rx_ntuple interface due to the
> fact that it supports many of the features I needed.

This still doesn't explain to me why a driver would set the feature
flag, but not actually implement the feature.

I'm not applying this patch.

When you create the situation that causes the potentially NULL
dereference, then you can use that patch to show why this seemingly
illogical situation can indeed occur.

Until then no driver causes this issue, therefore the problem does
not exist.

