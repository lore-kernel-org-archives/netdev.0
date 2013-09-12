From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.
Date: Thu, 12 Sep 2013 02:40:41 -0400 (EDT)
Message-ID: <20130912.024041.1357115695225954085.davem@davemloft.net>
References: <522C391A.3020408@redhat.com>
	<20130911.161606.1575635427616463157.davem@davemloft.net>
	<20130911231543.GA29725@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, david@unsolicited.net,
	fredo@starox.org, hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab3ILGkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 02:40:45 -0400
In-Reply-To: <20130911231543.GA29725@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 12 Sep 2013 01:15:43 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> Francois, if you reply to this thread with your signoff, all will
>> be well and I will apply this.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> I slowly built an AMD IOMMU + 8168{e/f} problem report pattern but
> the picture got blurred:
> - Hayes has not heard of anything like this
> - the oracle suggests it could be an "AMD IOMMU + whatever" problem
> - "iommu=pt" seems quite effective (hardly surprizing :o/ )
> 
> I still have a pile of iommu mailing-list messages to search through.
> Let aside the AMD-Vi error log message, I haven't done a thorough analysis.
> 
> It's lame.

Understood.  There were always IOMMU chips that sometimes prefetch one
cacheline too far (and thus potentially to the next page, which is
potentially unmapped) in certain circumstances.  Maybe these settings
trigger that kind of thing.

Applied and queued up for -stable, thanks.
