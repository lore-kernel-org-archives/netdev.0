From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: diag: Fix refcnt leak in error path destroying
 socket
Date: Tue, 23 Aug 2016 23:12:40 -0700 (PDT)
Message-ID: <20160823.231240.868460090939408317.davem@davemloft.net>
References: <1472011527-16760-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753371AbcHXGMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 02:12:41 -0400
In-Reply-To: <1472011527-16760-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 23 Aug 2016 21:05:27 -0700

> inet_diag_find_one_icsk takes a reference to a socket that is not
> released if sock_diag_destroy returns an error. Fix by changing
> tcp_diag_destroy to manage the refcnt for all cases and remove
> the sock_put calls from tcp_abort.
> 
> Fixes: c1e64e298b8ca ("net: diag: Support destroying TCP sockets")
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable.
