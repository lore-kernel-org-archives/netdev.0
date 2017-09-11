From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: broken vlan support on Realtek RTL8111/8168/8411 rev 9
Date: Tue, 12 Sep 2017 00:23:25 +0200
Message-ID: <20170911222325.GA23162@electric-eye.fr.zoreil.com>
References: <20170910191645.549d2a3a@krup.woody.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benoit Panizzon <benoit.panizzon@imp.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57686 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbdIKWXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 18:23:45 -0400
Content-Disposition: inline
In-Reply-To: <20170910191645.549d2a3a@krup.woody.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benoit Panizzon <benoit.panizzon@imp.ch> :
[...]
> It's not marked as fixed but:
> 
> when I try to turn offloading off I get:
> 
> # /sbin/ethtool -K eth0 rx-vlan-offload off
> ethtool: bad command line argument(s)
> For more information run ethtool -h
> 
> Could anyone give me a hint how to further debug the problem or disable
> vlan offloading completely?

ethtool -K eth0 rxvlan off

For my reward, please send a complete dmesg where the messages from
the vanilla r8169 module appear for the rev 09 card (r81..f ?). I won't
dig it right now.

-- 
Ueimor
