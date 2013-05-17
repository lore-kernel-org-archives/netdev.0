From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: listen on multiple ports
Date: Fri, 17 May 2013 14:06:55 -0700 (PDT)
Message-ID: <20130517.140655.2182995212892285929.davem@davemloft.net>
References: <20130516143520.581d1d78@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380Ab3EQVG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 17:06:57 -0400
In-Reply-To: <20130516143520.581d1d78@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 16 May 2013 14:35:20 -0700

> The commit 823aa873bc782f1c51b1ce8ec6da7cfcaf93836e
>   Author: stephen hemminger <stephen@networkplumber.org>
>   Date:   Sat Apr 27 11:31:57 2013 +0000
> 
>     vxlan: allow choosing destination port per vxlan
>     
> introduced per-vxlan UDP port configuration but only did half of the
> necessary work.  It added per vxlan destination for sending, but
> overlooked the handling of multiple ports for incoming traffic.
> 
> This patch changes the listening port management to handle multiple
> incoming UDP ports. The earlier per-namespace structure is now a hash
> list per namespace.
> 
> It is also now possible to define the same virtual network id
> but with different UDP port values which can be useful for migration.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

This is fine, but quite invasive, so I applied this to net-next.

Thanks.
