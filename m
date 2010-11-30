From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 19:14:57 -0800 (PST)
Message-ID: <20101129.191457.193722052.davem@davemloft.net>
References: <20101129.134403.179947389.davem@davemloft.net>
	<AANLkTimwo_ok=1dfzOST=rKqQdNS95wUAVdrrZHBMddS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53990
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750826Ab0K3DOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 22:14:30 -0500
In-Reply-To: <AANLkTimwo_ok=1dfzOST=rKqQdNS95wUAVdrrZHBMddS@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 30 Nov 2010 10:33:49 +0800

> I have thought about converting this AVL tree to rbtree. When I saw
> the comment above, I gave it up, because rbtree makes this structure
> bigger. If ipv6 support is added, I think it is time to turn to
> rbtree. :)

If it takes size over 128 bytes, it is probably still a bad idea.
Right now it is just under 128.
