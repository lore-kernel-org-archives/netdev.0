From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net/sched: act_csum: add support for
 SCTP checksum
Date: Mon, 09 Jan 2017 14:37:46 -0500 (EST)
Message-ID: <20170109.143746.1484194233149822491.davem@davemloft.net>
References: <cover.1483957003.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: dcaratti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754063AbdAIThs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:37:48 -0500
In-Reply-To: <cover.1483957003.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>
Date: Mon,  9 Jan 2017 11:24:19 +0100

> This series extends current act_csum functionality to allow computation of
> SCTP checksums. Patch 1 ensures LIBCRC32C will be selected if NET_ACT_CSUM
> is selected. Patch 2 extends act_csum to handle IPPROTO_SCTP protocol in
> IPv4/IPv6 header, and eventually compute the CRC32c value.
> 
> v2:
> - style fix in tc_csum.h
> - avoid nested if statement in act_csum.c

Series applied, thanks.
