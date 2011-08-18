From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 V2] bonding:reset backup and inactive flag of
 slave
Date: Wed, 17 Aug 2011 20:12:19 -0700 (PDT)
Message-ID: <20110817.201219.1929019096173738026.davem@davemloft.net>
References: <j2bgs2$pf5$1@dough.gmane.org>
	<8ed5a280dcc02566671810bcf7df83a05cb6a35d.1313459746.git.panweiping3@gmail.com>
	<j2dnte$p7a$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab1HRDMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 23:12:21 -0400
In-Reply-To: <j2dnte$p7a$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <xiyou.wangcong@gmail.com>
Date: Tue, 16 Aug 2011 12:30:39 +0000 (UTC)

> On Tue, 16 Aug 2011 09:57:35 +0800, Weiping Pan wrote:
> 
>> Eduard Sinelnikov (eduard.sinelnikov@gmail.com) found that if we change
>> bonding mode from active backup to round robin, some slaves are still
>> keeping "backup", and won't transmit packets.
>> 
>> As Jay Vosburgh(fubar@us.ibm.com) pointed out that we can work around
>> that by removing the bond_is_active_slave() check, because the "backup"
>> flag is only meaningful for active backup mode.
>> 
>> But if we just simply ignore the bond_is_active_slave() check, the
>> transmission will work fine, but we can't maintain the correct value of
>> "backup" flag for each slaves, though it is meaningless for other mode
>> than active backup.
>> 
>> I'd like to reset "backup" and "inactive" flag in bond_open, thus we can
>> keep the correct value of them.
>> 
>> As for bond_is_active_slave(), I'd like to prepare another patch to
>> handle it.
>> 
>> V2:
>> Use C style comment.
>> Move read_lock(&bond->curr_slave_lock). Replace restore with reset, for
>> active backup mode, it means "restore", but for other modes, it means
>> "reset".
>> 
>> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> 
> Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Applied, thanks.
