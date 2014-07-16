From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bonding: enhance L2 hash helper with packet type
Date: Wed, 16 Jul 2014 15:23:43 -0700 (PDT)
Message-ID: <20140716.152343.1176736920908144557.davem@davemloft.net>
References: <1405410083-26489-1-git-send-email-Jianhua.Xie@freescale.com>
	<20140715082028.GA28235@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jianhua.Xie@freescale.com, netdev@vger.kernel.org,
	j.vosburgh@gmail.com, andy@greyhouse.net, Jiafei.Pan@freescale.com
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbaGPWXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 18:23:45 -0400
In-Reply-To: <20140715082028.GA28235@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Tue, 15 Jul 2014 10:20:28 +0200

> On Tue, Jul 15, 2014 at 03:41:23PM +0800, Xie Jianhua wrote:
>>From: Jianhua Xie <jianhua.xie@freescale.com>
>>
>>Current L2 hash helper calculates destination eth addr and
>>source ether addr as L2 hash factors. This patch is adding
>>packet type ID field into hash factors, which can help to
>>distribute different types of packets like IPv4/IPv6 packets
>>to different slave devices while only BOND_XMIT_POLICY_LAYER2
>>is applied.
> 
> 1) It's also used in BOND_XMIT_POLICY_{LAYER|ENCAP}23, for the 2nd
> level
> hash.
> 2) The documentation (D/networking/bonding.txt) also needs an update.
> 
> Otherwise, looks good.

Please make these adjustments and resubmit this patch, thank you.
