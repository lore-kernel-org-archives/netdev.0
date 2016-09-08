From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Thu, 08 Sep 2016 16:13:48 -0700 (PDT)
Message-ID: <20160908.161348.297729487225819070.davem@davemloft.net>
References: <1473262945-144932-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, ek@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753569AbcIHXN5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 19:13:57 -0400
In-Reply-To: <1473262945-144932-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu,  8 Sep 2016 00:42:25 +0900

> This adds the capability for a process that has CAP_NET_ADMIN on
> a socket to see the socket mark in socket dumps.
> 
> Commit a52e95abf772 ("net: diag: allow socket bytecode filters to
> match socket marks") recently gave privileged processes the
> ability to filter socket dumps based on mark. This patch is
> complementary: it ensures that the mark is also passed to
> userspace in the socket's netlink attributes.  It is useful for
> tools like ss which display information about sockets.
> 
> Tested: https://android-review.googlesource.com/270210
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied, but the argument list of inet_sk_diag_fill is starting to get out
of control.
