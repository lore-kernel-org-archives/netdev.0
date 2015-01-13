From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: directly include libc-compat.h in ipv6.h
Date: Tue, 13 Jan 2015 16:33:01 -0500 (EST)
Message-ID: <20150113.163301.1001504354765052586.davem@davemloft.net>
References: <1421090974-30018-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbAMVdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:33:03 -0500
In-Reply-To: <1421090974-30018-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon, 12 Jan 2015 14:29:34 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> Patch 3b50d9029809 ("ipv6: fix redefinition of in6_pktinfo ...")
> fixed a libc compatibility issue in ipv6 structure definitions
> as described in include/uapi/linux/libc-compat.h.
> 
> It relies on including linux/in6.h to include libc-compat.h itself.
> Include that file directly to clearly communicate the dependency
> (libc-compat.h: "This include must be as early as possible").
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
