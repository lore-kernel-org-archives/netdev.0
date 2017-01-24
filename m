From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] Introduce a sysctl that modifies the value
 of PROT_SOCK.
Date: Tue, 24 Jan 2017 12:11:21 -0500 (EST)
Message-ID: <20170124.121121.1514357798997792255.davem@davemloft.net>
References: <20161231125505.7f0c7dff@xeon-e3>
        <20170112065225.GB2345@templeofstupid.com>
        <20170121014911.GB2598@templeofstupid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: kjlx@templeofstupid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50620 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdAXRLq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:11:46 -0500
In-Reply-To: <20170121014911.GB2598@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krister Johansen <kjlx@templeofstupid.com>
Date: Fri, 20 Jan 2017 17:49:11 -0800

> Add net.ipv4.ip_unprivileged_port_start, which is a per namespace sysctl
> that denotes the first unprivileged inet port in the namespace.  To
> disable all privileged ports set this to zero.  It also checks for
> overlap with the local port range.  The privileged and local range may
> not overlap.
> 
> The use case for this change is to allow containerized processes to bind
> to priviliged ports, but prevent them from ever being allowed to modify
> their container's network configuration.  The latter is accomplished by
> ensuring that the network namespace is not a child of the user
> namespace.  This modification was needed to allow the container manager
> to disable a namespace's priviliged port restrictions without exposing
> control of the network namespace to processes in the user namespace.
> 
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>

Applied, thanks.
