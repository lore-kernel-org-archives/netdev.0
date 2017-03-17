From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: sun: sungem: rix a possible null dereference
Date: Thu, 16 Mar 2017 20:38:38 -0700 (PDT)
Message-ID: <20170316.203838.1381913035641014041.davem@davemloft.net>
References: <1489614673-12595-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, edumazet@google.com, fw@strlen.de,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752431AbdCQDk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:40:28 -0400
In-Reply-To: <1489614673-12595-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed, 15 Mar 2017 22:51:13 +0100

> The function gem_begin_auto_negotiation dereference
> the pointer ep before testing if it's null. This
> patch add a check on ep before dereferencing it.
> 
> Fixes: 92552fdd557 ("net: sun: sungem: use new api

[davem@localhost net-next]$ git describe 92552fdd557
fatal: Not a valid object name 92552fdd557
[davem@localhost net-next]$

I don't know where you got that SHA1-ID, but it's not the one that
was actually used.

It is advised that you use Linus's or one of my GIT trees to find the
proper commit IDs.
