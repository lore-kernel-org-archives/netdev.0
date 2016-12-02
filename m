From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 net-next 0/6] net: Add bpf support for sockets
Date: Fri, 02 Dec 2016 13:46:52 -0500 (EST)
Message-ID: <20161202.134652.1237321538540148886.davem@davemloft.net>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLBSq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:46:59 -0500
In-Reply-To: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  1 Dec 2016 08:48:02 -0800

> The recently added VRF support in Linux leverages the bind-to-device
> API for programs to specify an L3 domain for a socket. While
> SO_BINDTODEVICE has been around for ages, not every ipv4/ipv6 capable
> program has support for it. Even for those programs that do support it,
> the API requires processes to be started as root (CAP_NET_RAW) which
> is not desirable from a general security perspective.
> 
> This patch set leverages Daniel Mack's work to attach bpf programs to
> a cgroup to provide a capability to set sk_bound_dev_if for all
> AF_INET{6} sockets opened by a process in a cgroup when the sockets
> are allocated.
 ...

Series applied, thanks David.
