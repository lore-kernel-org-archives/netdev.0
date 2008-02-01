From: Frans Pop <elendil@planet.nl>
Subject: Re: Typo in net/netfilter/xt_iprange.c (git tree)
Date: Fri, 01 Feb 2008 20:11:22 +0100
Message-ID: <E1JL1II-0002Qy-9u@faramir.fjphome.nl>
References: <47A32BEB.9040008@gmail.com>
Cc: jim.lkml@gmail.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml13.KPNXCHANGE.COM ([213.75.38.113]:53794 "EHLO
	hpsmtp-eml13.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754643AbYBATLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 14:11:24 -0500
In-reply-To: <47A32BEB.9040008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forward to netdev list.

--------------- Forwarded message (begin)
Subject: Typo in net/netfilter/xt_iprange.c (git tree)
From: Jiri Moravec <...>
Date: Fri, 01 Feb 2008 15:50:15 +0100

Function iprange_mt4 belong to IPv4 family - AF_INET. Right?

	.name      = "iprange",
	.revision  = 1,
	.family    = AF_INET6, <---------- Typo?
	.match     = iprange_mt4,
	.matchsize = sizeof(struct xt_iprange_mtinfo),
	.me        = THIS_MODULE,
--------------- Forwarded message (end)
