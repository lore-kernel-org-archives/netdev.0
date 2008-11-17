From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] isdn: remove extra byteswap in
 isdn_net_ciscohdlck_slarp_send_reply
Date: Sun, 16 Nov 2008 23:15:13 -0800
Message-ID: <1226906113.6150.5.camel@brick>
References: <1226895516.6150.4.camel@brick>
	 <20081116.230414.214811285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ZenIV.linux.org.uk, kkeil@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:17699 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbYKQHPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:15:16 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2481022wfd.4
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2008 23:15:15 -0800 (PST)
In-Reply-To: <20081116.230414.214811285.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-11-16 at 23:04 -0800, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Sun, 16 Nov 2008 20:18:36 -0800
> 
> > commit a144ea4b7a13087081ab5402fa9ad0bcfd249e67 [IPV4]: annotate struct in_ifaddr
> > 
> > Missed this extra byteswap as the isdn inlines hide the htonl inside put_u32
> > which causes an extra byteswap on little-endian arches.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> Applied, thanks.
> 
> > Dave, this is the minimal patch suitable to fix mainline without any net-next
> > material mixed in.  I'd suggest sending this one to Linus and then applying
> > my previous patch to net-next (if you need a resend, just ask)
> > 
> > Then whenever you do your net-next merge with Linus, the resolution should be trivial.
> 
> Please resend when I do my merges after Linus takes the change, I'll announce this
> on netdev as I always do.

OK, will do.

Harvey

