From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: smaller nla_attr_minlen table
Date: Sat, 19 Nov 2016 22:12:03 -0500 (EST)
Message-ID: <20161119.221203.37032690566080928.davem@davemloft.net>
References: <20161119005907.GE1200@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45906 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753126AbcKTDMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:12:05 -0500
In-Reply-To: <20161119005907.GE1200@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 19 Nov 2016 03:59:07 +0300

> Length of a netlink attribute may be u16 but lengths of basic attributes
> are much smaller, so small we can save 16 bytes of .rodata and pocket
> change inside .text.
> 
> 16-bit is worse on x86-64 than 8-bit because of operand size override prefix.
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next.
