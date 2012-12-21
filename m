From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] IP_MAX_MTU value
Date: Thu, 20 Dec 2012 23:08:50 -0800
Message-ID: <1356073730.21834.4917.camel@edumazet-glaptop>
References: <1356072468.21834.4805.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53491 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab2LUHIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 02:08:54 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so2616014pad.5
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 23:08:53 -0800 (PST)
In-Reply-To: <1356072468.21834.4805.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 22:47 -0800, Eric Dumazet wrote:

> It might be because in old days we reserved 16 bytes for the ethernet
> header, and we wanted to avoid kmalloc() round-up to kmalloc-131072
> slab ?

Well, we add the struct skb_shared_info anyway, so we hit kmalloc-131072
with current IP_MAX_MTU value...
