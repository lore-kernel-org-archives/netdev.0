From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/3] bridge: neigh msg proxy and flood
 suppression support
Date: Sun, 08 Oct 2017 21:12:18 -0700 (PDT)
Message-ID: <20171008.211218.2039744025968269985.davem@davemloft.net>
References: <1507353159-46814-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, makita.toshiaki@lab.ntt.co.jp,
        bridge@lists.linux-foundation.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750904AbdJIEMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:12:20 -0400
In-Reply-To: <1507353159-46814-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Fri,  6 Oct 2017 22:12:36 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This series implements arp and nd suppression in the bridge
> driver for ethernet vpns. It implements rfc7432, section 10
> https://tools.ietf.org/html/rfc7432#section-10
> for ethernet VPN deployments. It is similar to the existing
> BR_PROXYARP* flags but has a few semantic differences to conform
> to EVPN standard. Unlike the existing flags, this new flag suppresses
> flood of all neigh discovery packets (arp and nd) to tunnel ports.
> Supports both vlan filtering and non-vlan filtering bridges.
> 
> In case of EVPN, it is mainly used to avoid flooding
> of arp and nd packets to tunnel ports like vxlan.
> 
> v2 : rebase to latest + address some optimization feedback from Nikolay.
> v3 : fix kbuild reported build errors with CONFIG_INET off
> v4 : simplify port flag mask as suggested by stephen
> v5 : address some feedback from Toshiaki
> v6 : some v5 cleanups in nd suppress (keep it consistent with arp suppress)

Series applied, thank you.
