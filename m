From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Set flow-key members.
Date: Fri, 17 Oct 2014 23:55:15 -0400 (EDT)
Message-ID: <20141017.235515.1327759792955010942.davem@davemloft.net>
References: <1413579391-1470-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbaJRDzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:55:16 -0400
In-Reply-To: <1413579391-1470-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri, 17 Oct 2014 13:56:31 -0700

> This patch adds missing memset which are required to initialize
> flow key member. For example for IP flow we need to initialize
> ip.frag for all cases.
> 
> Found by inspection.
> 
> This bug is introduced by commit 0714812134d7dcadeb7ecfbfeb18788aa7e1eaac
> ("openvswitch: Eliminate memset() from flow_extract").
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
