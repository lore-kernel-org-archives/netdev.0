From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/27] Allow passing of VLAN CFI bit
 through network stack
Date: Tue, 03 Jan 2017 16:32:17 -0500 (EST)
Message-ID: <20170103.163217.697324652959765171.davem@davemloft.net>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
        <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758787AbdACVdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 16:33:35 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha©© Miros©©aw <mirq-linux@rere.qmqm.pl>
Date: Tue,  3 Jan 2017 21:52:33 +0100 (CET)

> Dear NetDevs
> 
> This series removes an abuse of VLAN CFI bit in Linux networking stack.
> Currently Linux always clears the bit on outgoing traffic and presents
> it cleared to userspace (even via AF_PACKET/tcpdump when hw-accelerated).
> 
> This uses a new vlan_present bit in struct skbuff, and removes an assumption
> that vlan_proto != 0 when VLAN tag is present.
> 
> As I can't test most of the driver changes, please look at them carefully.
> 
> The series is supposed to be bisect-friendly and that requires temporary
> insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
> JIT changes per architecture.
> 
> Best Regards,
> Micha©© Miros©©aw
> 
> v2: rebase onto net-next

This patch series is really way too large.

You're going to have to find a way to combine related changes, or submit
this as a series of logical sets, one at a time.

Thanks.
