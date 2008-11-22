From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB
 to the kernel and ixgbe driver
Date: Fri, 21 Nov 2008 16:48:12 -0800 (PST)
Message-ID: <20081121.164812.237199469.davem@davemloft.net>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	<4926B26C.7010200@trash.net>
	<adaabbtgdv6.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36953
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752250AbYKVAsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:48:13 -0500
In-Reply-To: <adaabbtgdv6.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 21 Nov 2008 09:58:37 -0800

>  > > +
>  > > +config DCBNL
>  > > +	bool "Data Center Bridging netlink interface support"
>  > > +	depends on DCB
>  > > +	default n
>  > > +	---help---
>  > > +	  This option turns on the netlink interface
>  > > +	  (dcbnl) for Data Center Bridging capable devices.
>  > > +
>  > > +	  If unsure, say N.
> 
> Now that I look at this config, it looks rather strange.  When does is
> ever make sense to enable DCB but not DCBNL?  How else does one
> configure all the DCB parameters except by running dcbd in userspace?
> Should there even be a separate DCBNL option at all?

Yes, that makes sense.

If DCBNL is the only way to enable and control DCB, there is no sense
to have two seperate options.
