From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Tue, 19 Feb 2008 14:17:57 -0800 (PST)
Message-ID: <20080219.141757.213666958.davem@davemloft.net>
References: <47BAEE3B.7020502@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762965AbYBSWRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 17:17:22 -0500
In-Reply-To: <47BAEE3B.7020502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 19 Feb 2008 15:56:59 +0100

>     [NET]: Messed multicast lists after dev_mc_sync/unsync
>     
>     Commit a0a400d79e3dd7843e7e81baa3ef2957bdc292d0 from you
>     introduced a new field "da_synced" to struct dev_addr_list that is
>     not properly initialized to 0. So when any of the current users (8021q,
>     macvlan, mac80211) calls dev_mc_sync/unsync they mess the address
>     list for both devices.
>     
>     The attached patch fixed it for me and avoid future problems.
>     
>     Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

I've added the headline description of the referenced commit
to this commit message, and will queue this up to -stable.

Thanks!
