From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnx2x: Fix malicious VFs indication
Date: Sat, 10 Jun 2017 16:03:19 -0400 (EDT)
Message-ID: <20170610.160319.846840483652390189.davem@davemloft.net>
References: <20170609141702.20688-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdFJUDV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:03:21 -0400
In-Reply-To: <20170609141702.20688-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Fri, 9 Jun 2017 17:17:00 +0300

> It was discovered that for a VF there's a simple [yet uncommon] scenario
> which would cause device firmware to declare that VF as malicious -
> Add a vlan interface on top of a VF and disable txvlan offloading for
> that VF [causing VF to transmit packets where vlan is on payload].
> 
> Patch #1 corrects driver transmission to prevent this issue.
> Patch #2 is a by-product correcting PF behavior once a VF is declared
> malicious.

Series applied, thank you.
