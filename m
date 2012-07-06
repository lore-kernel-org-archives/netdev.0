From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: net-next warning at kernel/softirq.c:159 local_bh_enable
Date: Fri, 6 Jul 2012 07:22:44 +0300
Message-ID: <CAJZOPZ+vvsZkeq39AsmmaXvWcajb1f+Q0oB8hi9eJiUWUFirZw@mail.gmail.com>
References: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
	<20120705.210832.1951884287116053841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	shlomop@mellanox.com, Erez Shitrit <erezsh@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:49462 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237Ab2GFEWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 00:22:45 -0400
Received: by ghrr11 with SMTP id r11so8208022ghr.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 21:22:44 -0700 (PDT)
In-Reply-To: <20120705.210832.1951884287116053841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Here is what I commited to fix this:
>
> ====================
> [PATCH] ipoib: Need to do dst_neigh_lookup_skb() outside of priv->lock.
>
> Otherwise local_bh_enable() complains.

sorry, I missed your note, I just pulled from kernel.org and it
doesn't have the commit, will
be able to test that later.

Or.
