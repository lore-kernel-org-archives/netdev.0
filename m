From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC v1 00/27] afnetns: new namespace type for
 separation on protocol level
Date: Sun, 12 Mar 2017 16:26:13 -0700 (PDT)
Message-ID: <20170312.162613.1105038945335893886.davem@davemloft.net>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755789AbdCLX0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:26:17 -0400
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 13 Mar 2017 00:01:24 +0100

> afnetns behaves like ordinary namespaces: clone, unshare, setns syscalls
> can work with afnetns with one limitation: one cannot cross the realm
> of a network namespace while changing the afnetns compartement. To get
> into a new afnetns in a different net namespace, one must first change
> to the net namespace and afterwards switch to the desired afnetns.

Please explain why this is useful, who wants this kind of facility,
and how it will be used.

Thank you.
