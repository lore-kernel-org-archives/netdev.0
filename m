From: David Miller <davem@davemloft.net>
Subject: Re: Use sock_diag instead of procfs for new address families?
Date: Tue, 18 Jul 2017 10:46:57 -0700 (PDT)
Message-ID: <20170718.104657.545966026047818509.davem@davemloft.net>
References: <20170718161806.GA21151@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        jhansen@vmware.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751431AbdGRRq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 13:46:57 -0400
In-Reply-To: <20170718161806.GA21151@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Tue, 18 Jul 2017 17:18:06 +0100

> I am implementing userspace access to socket information for AF_VSOCK.
> A few hours into writing and testing a /proc/net/vsock seq_file I
> noticed that ss(8) prefers NETLINK_SOCK_DIAG over procfs.
> 
> Before potentially wasting time implementing a legacy interface that
> won't be accepted, I thought it might be good to ask :).
> 
> Which approach is preferred?
> 1. New address families must implement only sock_diag.
> 2. Both sock_diag and procfs must be implemented.
> 3. Implement whichever interface you prefer.

Do not use procfs, that is for sure.
