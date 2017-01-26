From: David Miller <davem@davemloft.net>
Subject: Re: netvsc NAPI patch process
Date: Thu, 26 Jan 2017 13:06:46 -0500 (EST)
Message-ID: <20170126.130646.2180422281199593870.davem@davemloft.net>
References: <20170126100405.0eac2dea@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, greg@kroah.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753880AbdAZSav (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:30:51 -0500
In-Reply-To: <20170126100405.0eac2dea@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 26 Jan 2017 10:04:05 -0800

> I have a working set of patches to enable NAPI in the netvsc driver.
> The problem is that it requires a set of patches to vmbus layer as well.
> Since vmbus patches have been going through char-misc-next tree rather
> than net-next, it is difficult to stage these.
> 
> How about if I send the vmbus patches through normal driver-devel upstream
> and during the 4.10 merge window send the last 3 patches for NAPI for linux-net
> tree to get into 4.10?

Another option is that the char-misc-next folks create a branch with just
the commits you need for NAPI, I pull that into net-next, and then you
can submit the NAPI changes to me.
