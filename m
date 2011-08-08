From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix ip_getsockopt for IP_PKTOPTIONS
Date: Sun, 07 Aug 2011 22:31:16 -0700 (PDT)
Message-ID: <20110807.223116.2298990983412513029.davem@davemloft.net>
References: <1312672850-13676-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, tszocs@ixiacom.com
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab1HHFfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:35:14 -0400
In-Reply-To: <1312672850-13676-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <dbaluta@ixiacom.com>
Date: Sun,  7 Aug 2011 02:20:50 +0300

> IP_PKTOPTIONS is broken for 32-bit applications running
> in COMPAT mode on 64-bit kernels.
> 
> This happens because msghdr's msg_flags field is always
> set to zero. When running in COMPAT mode this should be
> set to MSG_CMSG_COMPAT instead.
> 
> Signed-off-by: Tiberiu Szocs-Mihai <tszocs@ixiacom.com>
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>

Applied, thanks.
