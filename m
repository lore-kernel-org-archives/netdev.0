From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples/bpf: adjust rlimit RLIMIT_MEMLOCK for
 xdp1
Date: Sun, 29 Oct 2017 12:18:21 +0900 (KST)
Message-ID: <20171029.121821.738376742933062479.davem@davemloft.net>
References: <1509145950-5840-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
To: tushar.n.dave@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbdJ2DSZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 23:18:25 -0400
In-Reply-To: <1509145950-5840-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>
Date: Fri, 27 Oct 2017 16:12:30 -0700

> Default rlimit RLIMIT_MEMLOCK is 64KB, causes bpf map failure.
> e.g.
> [root@lab bpf]#./xdp1 -N $(</sys/class/net/eth2/ifindex)
> failed to create a map: 1 Operation not permitted
> 
> Fix it.
> 
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>

Applied.
