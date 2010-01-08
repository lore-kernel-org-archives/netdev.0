From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/5] ixgbe: Add Flow Director
 configuration support as a mod parameter
Date: Fri, 08 Jan 2010 00:32:44 -0800 (PST)
Message-ID: <20100108.003244.67199934.davem@davemloft.net>
References: <20100107044928.28605.62132.stgit@localhost.localdomain>
	<20100108.002449.190520102.davem@davemloft.net>
	<Pine.WNT.4.64.1001080027500.15300@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, deri@ntop.org, joseph.gasparakis@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751112Ab0AHIcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:32:35 -0500
In-Reply-To: <Pine.WNT.4.64.1001080027500.15300@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 8 Jan 2010 00:28:17 -0800 (Pacific Standard Time)

> On Fri, 8 Jan 2010, David Miller wrote:
> 
>> Use a generic ethtool boolean flag or similar, not "yet another
>> different-in-every-driver" module parameter please.
> 
> Something added to the setflags routine perhaps?

Yeah, something via 'struct ethtool_flags' is probably appropriate.
