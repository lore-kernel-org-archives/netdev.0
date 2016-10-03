From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
Date: Sun, 02 Oct 2016 23:48:31 -0400 (EDT)
Message-ID: <20161002.234831.149876659535482615.davem@davemloft.net>
References: <1475134423-23635-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org, ek@google.com,
        lorenzo@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbcJCDsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2016 23:48:38 -0400
In-Reply-To: <1475134423-23635-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Thu, 29 Sep 2016 00:33:43 -0700

> From: Maciej ¯enczykowski <maze@google.com>
> 
> This is an effective no-op in terms of user observable behaviour.
> 
> By preventing the overwrite of non-null extra1/extra2 fields
> in addrconf_sysctl() we can enable the use of proc_dointvec_minmax().
> 
> This allows us to eliminate the constant min/max (1..255) trampoline
> function that is addrconf_sysctl_hop_limit().
> 
> This is nice because it simplifies the code, and allows future
> sysctls with constant min/max limits to also not require trampolines.
> 
> We still can't eliminate the trampoline for mtu because it isn't
> actually a constant (it depends on other tunables of the device)
> and thus requires at-write-time logic to enforce range.
> 
> Signed-off-by: Maciej ¯enczykowski <maze@google.com>

Applied, thanks.
