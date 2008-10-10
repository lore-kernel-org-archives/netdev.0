From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: e1000: allow VLAN devices to use TSO and CSUM
 offload
Date: Fri, 10 Oct 2008 15:11:56 -0700 (PDT)
Message-ID: <20081010.151156.186628285.davem@davemloft.net>
References: <1223661576.3984.114.camel@achroite>
	<20081010.120905.132001378.davem@davemloft.net>
	<36D9DB17C6DE9E40B059440DB8D95F52066726B7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, kaber@trash.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754112AbYJJWMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 18:12:20 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52066726B7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Fri, 10 Oct 2008 15:01:09 -0700

> David Miller wrote:
> >> vlan_features is a mask for features.  So long as all parts that do
> >> support TSO-IPv6 also support it for VLAN-tagged packets, it should
> >> be safe to set NETIF_F_TSO6 in vlan_features unconditionally.
> > 
> > Right, it's an additional mask which gets and'd with the normal
> > device feature bits.
> > 
> > Jesse, any objections, given that?
> 
> No, once that is explained I think it gets rid of any objections.  We
> are going to test the patch now, so would you mind if you waited to take
> it until jkirsher pushes it to you?

Sure, no problem.
