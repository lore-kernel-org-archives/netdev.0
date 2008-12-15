From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/2] net: add error return for dcb setstate
Date: Mon, 15 Dec 2008 01:05:29 -0800 (PST)
Message-ID: <20081215.010529.26091839.davem@davemloft.net>
References: <20081212095221.4416.83327.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, eric.w.multanen@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56758
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752209AbYLOJF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 04:05:28 -0500
In-Reply-To: <20081212095221.4416.83327.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Dec 2008 01:52:21 -0800

> DCB had no way to know if setstate had failed in the driver. This
> patch enables dcb netlink code to handle the status for the DCB
> setstate interface.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

How can this build if you don't also update ixgbe_dcbnl_set_state() et
al. to have a "u8" instead of a "void" return value too?

Oh I see, you send the update two patches later.

Don't do that, it breaks GIT bisect.

If you change the prototype for a method function, you must also
change all implementations of that method to match at the same time.

I've dropped both changes.
