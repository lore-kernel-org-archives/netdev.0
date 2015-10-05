From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix ovs_vport_get_stats()
Date: Mon, 05 Oct 2015 07:07:46 -0700 (PDT)
Message-ID: <20151005.070746.2242001172847714284.davem@davemloft.net>
References: <1443822994-1928-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomasz.sawicki@objectiveintegration.uk
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbJENwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:52:14 -0400
In-Reply-To: <1443822994-1928-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri,  2 Oct 2015 14:56:34 -0700

> Not every device has dev->tstats set. So when OVS tries to calculate
> vport stats it causes kernel panic. Following patch fixes it by
> using standard API to get net-device stats.
 ...
> Reported-by: Tomasz Sawicki <tomasz.sawicki@objectiveintegration.uk>
> Fixes: 8c876639c98 ("openvswitch: Remove vport stats.")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
