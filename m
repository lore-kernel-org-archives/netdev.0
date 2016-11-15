From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH 2/2] ipv4: Fix memory leak in exception case for
 splitting tries
Date: Tue, 15 Nov 2016 10:24:10 -0800
Message-ID: <1479234250.8455.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
         <20161115104612.13711.44592.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32861 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753270AbcKOSYM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:24:12 -0500
Received: by mail-pf0-f193.google.com with SMTP id 144so8364653pfv.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:24:11 -0800 (PST)
In-Reply-To: <20161115104612.13711.44592.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-15 at 05:46 -0500, Alexander Duyck wrote:
> Fix a small memory leak that can occur where we leak a fib_alias in the
> event of us not being able to insert it into the local table.
> 
> Fixes: 0ddcf43d5d4a0 ("ipv4: FIB Local/MAIN table collapse")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  net/ipv4/fib_trie.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
