From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: remove extra byteswap in
 isdn_net_ciscohdlck_slarp_send_reply
Date: Sun, 16 Nov 2008 23:04:14 -0800 (PST)
Message-ID: <20081116.230414.214811285.davem@davemloft.net>
References: <1226895516.6150.4.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ZenIV.linux.org.uk, kkeil@suse.de
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59197
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751418AbYKQHEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:04:14 -0500
In-Reply-To: <1226895516.6150.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Sun, 16 Nov 2008 20:18:36 -0800

> commit a144ea4b7a13087081ab5402fa9ad0bcfd249e67 [IPV4]: annotate struct in_ifaddr
> 
> Missed this extra byteswap as the isdn inlines hide the htonl inside put_u32
> which causes an extra byteswap on little-endian arches.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks.

> Dave, this is the minimal patch suitable to fix mainline without any net-next
> material mixed in.  I'd suggest sending this one to Linus and then applying
> my previous patch to net-next (if you need a resend, just ask)
> 
> Then whenever you do your net-next merge with Linus, the resolution should be trivial.

Please resend when I do my merges after Linus takes the change, I'll announce this
on netdev as I always do.
