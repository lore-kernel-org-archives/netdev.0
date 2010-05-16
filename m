From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: make SR-IOV VF interface symmetric
Date: Sun, 16 May 2010 01:05:59 -0700 (PDT)
Message-ID: <20100516.010559.133392397.davem@davemloft.net>
References: <20100515031416.GE15313@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, mitch.a.williams@intel.com, arnd@arndb.de,
	scofeldm@cisco.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40996
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753166Ab0EPIFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 04:05:55 -0400
In-Reply-To: <20100515031416.GE15313@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Wright <chrisw@sous-sol.org>
Date: Fri, 14 May 2010 20:14:16 -0700

> Now we have a set of nested attributes:
> 
>   IFLA_VFINFO_LIST (NESTED)
>     IFLA_VF_INFO (NESTED)
>       IFLA_VF_MAC
>       IFLA_VF_VLAN
>       IFLA_VF_TX_RATE
> 
> This allows a single set to operate on multiple attributes if desired.
> Among other things, it means a dump can be replayed to set state.
> 
> The current interface has yet to be released, so this seems like
> something to consider for 2.6.34.
> 
> Signed-off-by: Chris Wright <chrisw@sous-sol.org

Agreed, applied to net-2.6, thanks Chris!
