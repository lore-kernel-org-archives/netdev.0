From: David Miller <davem@davemloft.net>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Sat, 09 May 2009 22:54:57 -0700 (PDT)
Message-ID: <20090509.225457.237499573.davem@davemloft.net>
References: <1241433136.6126.70.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42754
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbZEJFzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 01:55:03 -0400
In-Reply-To: <1241433136.6126.70.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 04 May 2009 11:32:16 +0100

> This patch adds three attribute files in /sys/class/net/$dev/ for tun
> devices; allowing userspace to obtain the information which TUNGETIFF
> offers, and more, but without having to attach to the device in question
> (which may not be possible if it's in use).
> 
> It also fixes a bug which has been present in the TUNGETIFF ioctl since
> its inception, where it would never set IFF_TUN or IFF_TAP according to
> the device type. (Look carefully at the code which I remove from
> tun_get_iff() and how the new tun_flags() helper is subtly different).
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied to net-next-2.6, thanks!
