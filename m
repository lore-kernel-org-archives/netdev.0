From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] bpf: Remove the capability check for
 cgroup skb eBPF program
Date: Fri, 02 Jun 2017 14:25:08 -0400 (EDT)
Message-ID: <20170602.142508.34027526876686323.davem@davemloft.net>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
        <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdFBSZK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:25:10 -0400
In-Reply-To: <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Wed, 31 May 2017 18:16:00 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> Currently loading a cgroup skb eBPF program require a CAP_SYS_ADMIN
> capability while attaching the program to a cgroup only requires the
> user have CAP_NET_ADMIN privilege. We can escape the capability
> check when load the program just like socket filter program to make
> the capability requirement consistent.
> 
> Change since v1:
> Change the code style in order to be compliant with checkpatch.pl
> preference
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Applied.
