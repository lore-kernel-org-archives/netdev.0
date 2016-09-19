From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 next 0/3] IPvlan introduce l3s mode
Date: Mon, 19 Sep 2016 01:25:53 -0400 (EDT)
Message-ID: <20160919.012553.2296021393161610588.davem@davemloft.net>
References: <1474055941-12353-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755710AbcISFZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:25:57 -0400
In-Reply-To: <1474055941-12353-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Fri, 16 Sep 2016 12:59:01 -0700

> Same old problem with new approach especially from suggestions from
> earlier patch-series.
> 
> First thing is that this is introduced as a new mode rather than
> modifying the old (L3) mode. So the behavior of the existing modes is
> preserved as it is and the new L3s mode obeys iptables so that intended
> conn-tracking can work. 
> 
> To do this, the code uses newly added l3mdev_rcv() handler and an
> Iptables hook. l3mdev_rcv() to perform an inbound route lookup with the
> correct (IPvlan slave) interface and then IPtable-hook at LOCAL_INPUT
> to change the input device from master to the slave to complete the
> formality.
> 
> Supporting stack changes are trivial changes to export symbol to get
> IPv4 equivalent code exported for IPv6 and to allow netfilter hook
> registration code to allow caller to hold RTNL. Please look into
> individual patches for details.

Series applied, thanks.
