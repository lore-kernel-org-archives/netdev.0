From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/8] e1000e: cleanup ethtool loopback
 setup code
Date: Wed, 30 Jun 2010 16:06:15 -0700 (PDT)
Message-ID: <20100630.160615.179276491.davem@davemloft.net>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
	<20100618.221512.102550313.davem@davemloft.net>
	<8DD2590731AB5D4C9DBF71A877482A9001591F6130@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58773
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755399Ab0F3XGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 19:06:04 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9001591F6130@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Date: Wed, 30 Jun 2010 15:41:19 -0700

> I've been looking into your request number 2 above (as a reminder,
> it had to do with a patch I submitted that added a module parameter
> to e1000e in order to enable/disable Energy Efficient Ethernet for a
> particular type of adapter).
> 
> For this new ethtool feature bit/flag for EEE, would you prefer it be set via:
> 1) the generic parameter setting option (e.g. -s ethX [eee on|off]),
> 2) yet another new show/change option pair, or
> 3) a new option that can set this new feature and be expandable to future features that are likewise not related to existing ethtool options (e.g. -F [eee on|off] [whizbang on|off])?
> 
> For #2 or #3, it makes sense to use ethtool_op_[g|s]et_flags with
> new ETH_FLAG_<feature> and NETIF_F_<feature> defines, but #1 can be
> implemented that way or by using remaining reserved elements of
> struct ethtool_cmd - if your preference is for #1, would you prefer
> it be implemented with the former or latter?

I only have strong feelings about the kernel side, and an ETH_FLAG_* seems
best for this since other devices will have this feature too.

I don't think overloading parts of ethtool_cmd is wise.
