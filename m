From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] igb: use build_skb()
Date: Mon, 06 Aug 2012 20:21:55 +0200
Message-ID: <1344277315.26674.54.camel@edumazet-glaptop>
References: <1343922692.9299.231.camel@edumazet-glaptop>
	 <50200066.6060905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56794 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347Ab2HFSWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 14:22:00 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so1147352bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 11:21:59 -0700 (PDT)
In-Reply-To: <50200066.6060905@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 10:35 -0700, Alexander Duyck wrote:

> I was planning to move igb over to an ixgbe style receive path at some
> point anyway.  Since it seems like this is now a higher priority I
> figured I would try to get the patches for it implemented in the next
> week or so.  Would there be any issue with us rejecting this patch and
> instead switching igb over to the ixgbe style path?

It seems I missed this part.

I use igb on my dev machine, not on prod machines, so if you are moving
igb to ixgbe, I can certainly can maintain my patch in my tree, while
you make your changes.
