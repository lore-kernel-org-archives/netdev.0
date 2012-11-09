From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Thu, 08 Nov 2012 18:37:55 -0800
Message-ID: <1352428675.19779.490.camel@edumazet-glaptop>
References: <1335522818.2775.227.camel@edumazet-glaptop>
	 <509A19E6.4040707@gmail.com>  <509A1D49.4080306@gmail.com>
	 <1352286264.3140.3575.camel@edumazet-glaptop> <509B6368.9010206@gmail.com>
	 <1352381449.19779.13.camel@edumazet-glaptop> <509C6AEF.4020300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56862 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964Ab2KICh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 21:37:57 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so2437875pad.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 18:37:57 -0800 (PST)
In-Reply-To: <509C6AEF.4020300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 10:31 +0800, Li Yu wrote:

> I think that adding skb->frag_head indeed is a better choice, this means 
> I have to rework some NIC drivers :(

Not sure what you mean, since most (if not all) NIC drivers already use
skb->frag_head in their RX path.
