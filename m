From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: avoid dad-failures for addresses with NODAD
Date: Mon, 15 May 2017 14:26:55 -0400 (EDT)
Message-ID: <20170515.142655.1279898304018190599.davem@davemloft.net>
References: <20170513000339.15843-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, edumazet@google.com,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934127AbdEOS05 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:26:57 -0400
In-Reply-To: <20170513000339.15843-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Fri, 12 May 2017 17:03:39 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> Every address gets added with TENTATIVE flag even for the addresses with
> IFA_F_NODAD flag and dad-work is scheduled for them. During this DAD process
> we realize it's an address with NODAD and complete the process without
> sending any probe. However the TENTATIVE flags stays on the
> address for sometime enough to cause misinterpretation when we receive a NS.
> While processing NS, if the address has TENTATIVE flag, we mark it DADFAILED
> and endup with an address that was originally configured as NODAD with
> DADFAILED.
> 
> We can't avoid scheduling dad_work for addresses with NODAD but we can
> avoid adding TENTATIVE flag to avoid this racy situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

This doesn't apply cleanly to the net tree, please respin.

Thank you.
