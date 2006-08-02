From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 5/23] [PATCH] [XFRM] STATE: Add source address list.
Date: Wed, 02 Aug 2006 10:42:51 +0900
Message-ID: <44D0031B.8050509@linux-ipv6.org>
References: <11541654121350-git-send-email-nakam@linux-ipv6.org> <20060801.165728.18308673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:57489 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1750967AbWHBBmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 21:42:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.165728.18308673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> This is a userspace exported structure, therefore you cannot
> make changes to it like this, it will break the userland API.

OK.

> If you need to provide the source address, you need to pass it in via
> a new xfrm netlink attribute or use an existing data structure member
> which records the source address (if any such thing does exist).

There is no xfrm netlink attribute to carry source address.
I'll add it like XFRMA_SRCADDR.

BTW another patch newly defined XFRMA_ADDR to carry care-of address.
This would be changed e.g. XFRMA_COADDR or something, too.

-- 
Masahide NAKAMURA
