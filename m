From: David Lamparter <equinox@diac24.net>
Subject: Re: Invalid Argument when adding a bond to a bridge
Date: Thu, 22 Dec 2011 15:35:55 +0100
Message-ID: <20111222143555.GB1054159@jupiter.n2.diac24.net>
References: <b8003b95089e177b00bc7db44700757a@pl1.haspere.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>,
	Bridge <bridge@lists.linux-foundation.org>,
	Bonding Devel <bonding-devel@lists.sourceforge.net>
To: Dyweni - NetDev <xmCM8KtKk25K@dyweni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:56762 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab1LVOgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 09:36:03 -0500
Content-Disposition: inline
In-Reply-To: <b8003b95089e177b00bc7db44700757a@pl1.haspere.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an interface to the bond, then add the bond to the bridge.

bond without interface = 00:00:00:00:00:00 MAC = invalid.

On Thu, Dec 22, 2011 at 08:25:54AM -0600, Dyweni - NetDev wrote:
>  I created the bond with: echo "+x" > /sys/class/net/bonding_masters
> 
>  I created the bridge with: brctl addbr b
> 
>  I try to add the bond to the bridge with: brctl addif b x
