From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/2] bonding: enhance L2 hash helper with packet
 type
Date: Thu, 17 Jul 2014 16:03:43 -0700 (PDT)
Message-ID: <20140717.160343.1783895434915972439.davem@davemloft.net>
References: <1405577786-28811-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, Jiafei.Pan@freescale.com
To: Jianhua.Xie@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757990AbaGQXDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 19:03:44 -0400
In-Reply-To: <1405577786-28811-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xie Jianhua <Jianhua.Xie@freescale.com>
Date: Thu, 17 Jul 2014 14:16:25 +0800

> From: Jianhua Xie <jianhua.xie@freescale.com>
> 
> Current L2 hash helper calculates destination eth addr and
> source ether addr as L2 hash factors.  This patch is adding
> packet type ID field into L2 hash factors.  While one of
> BOND_XMIT_POLICY_LAYER2 or BOND_XMIT_POLICY_{LAYER|ENCAP}23
> is applied, for the 2nd level hash, enhanced hash method can
> help to distribute different types of packets like IPv4/IPv6
> packets to different slave devices.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> CC: Pan Jiafei <Jiafei.Pan@freescale.com>
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>

Applied.
