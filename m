From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: bugfix in isdn_net_ciscohdlck_slarp_send_reply,
 trivial sparse fixes
Date: Sun, 16 Nov 2008 19:54:06 -0800 (PST)
Message-ID: <20081116.195406.196992095.davem@davemloft.net>
References: <1226684029.5483.12.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, kkeil@suse.de, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755750AbYKQDyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 22:54:08 -0500
In-Reply-To: <1226684029.5483.12.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Fri, 14 Nov 2008 09:33:49 -0800

> commit a144ea4b7a13087081ab5402fa9ad0bcfd249e67 [IPV4]: annotate struct in_ifaddr
> 
> Missed the extra byteswap because the previous isdn inline helpers
> hid the extra htonl inside put_u32.  This was causing an extra byteswap
> on little-endian arches.
> 
> While here, do the trivial annotation of the struct ip_ports and change
> the remaining casts to __be16 where applicable.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Dave, the yesterday's patch was a zero-change patch that exposed this
> bug, this patch changes behavior in the above-referenced function.

Well, you've created an incredibly difficult situation for me.

The bug exists in 2.6.28-rcX but your cleanup patch was only appropriate
for net-next-2.6 so that's where it went.

But this bug fix here will only apply on top of that cleanup.

This is wrong, please propose a way to correct this so that 2.6.28-rcX can
get this bug fixed properly, without a dependency on a cleanup with is
not appropriate for 2.6.28-rcX.
