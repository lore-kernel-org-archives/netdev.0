From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Zero ifla_vf_info in rtnl_fill_vfinfo()
Date: Thu, 08 Jun 2017 10:58:41 -0400 (EDT)
Message-ID: <20170608.105841.978006950240671178.davem@davemloft.net>
References: <20170607180033.19747-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751597AbdFHO6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:58:43 -0400
In-Reply-To: <20170607180033.19747-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Wed, 7 Jun 2017 21:00:33 +0300

> Some of the structure's fields are not initialized by the
> rtnetlink. If driver doesn't set those in ndo_get_vf_config(),
> they'd leak memory to user.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> CC: Michal Schmidt <mschmidt@redhat.com>

Good catch, applied and queued up for -stable, thanks.
