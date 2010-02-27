From: David Miller <davem@davemloft.net>
Subject: Re: bonding: fix device leak on error in bond_create()
Date: Sat, 27 Feb 2010 02:52:36 -0800 (PST)
Message-ID: <20100227.025236.215054636.davem@davemloft.net>
References: <4B87EA58.7090601@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965301Ab0B0KwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 05:52:18 -0500
In-Reply-To: <4B87EA58.7090601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 26 Feb 2010 16:35:52 +0100

> commit f357a5caa0ca29b74811a0fc08efb5ae4aade959
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Feb 25 20:21:10 2010 +0100
> 
>     bonding: fix device leak on error in bond_create()
>     
>     When the register_netdevice() call fails, the newly allocated device is
>     not freed.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

I think whether we should be checking for negative return values is
not something to gripe over, so I've applied this, thanks!
