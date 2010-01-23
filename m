From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in
 vlan_skb_recv - probably introduced by commit
 9793241fe92f7d9303fb221e43fc598eb065f267
Date: Sat, 23 Jan 2010 22:31:32 +0100
Message-ID: <20100123223132.0e62d8cb@neptune.home>
References: <20100123165657.187c11e4@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp-157-144.adsl.restena.lu ([158.64.157.144]:42379 "EHLO
	bonbons.gotdns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab0AWVcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 16:32:01 -0500
In-Reply-To: <20100123165657.187c11e4@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Above part of code did change between 2.6.32 and 2.6.33-rc5 with
> commit 9793241fe92f7d9303fb221e43fc598eb065f267 (vlan: Precise RX
> stats accounting)
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=9793241fe92f7d9303fb221e43fc598eb065f267

Reverting just that commit gets the system running correctly.

Bruno
