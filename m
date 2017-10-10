From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] nfp: fix ethtool stats and page allocation
Date: Tue, 10 Oct 2017 13:18:48 -0700 (PDT)
Message-ID: <20171010.131848.1224943700020587506.davem@davemloft.net>
References: <20171010161623.23838-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934566AbdJJUSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:18:49 -0400
In-Reply-To: <20171010161623.23838-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 10 Oct 2017 09:16:21 -0700

> Two fixes for net.  First one makes sure we handle gather of stats on
> 32bit machines correctly (ouch).  The second fix solves a potential
> NULL-deref if we fail to allocate a page with XDP running.
> 
> I used Fixes: tags pointing to where the bug was introduced, but for
> patch 1 it has been in the driver "for ever" and fix won't backport
> cleanly beyond commit 325945ede6d4 ("nfp: split software and hardware 
> vNIC statistics") which is in net.

Series applied, thanks Jakub.
