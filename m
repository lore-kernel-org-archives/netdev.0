From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-2.6 V2] bonding:reset backup and inactive flag of
 slave
Date: Tue, 16 Aug 2011 12:30:39 +0000 (UTC)
Message-ID: <j2dnte$p7a$1@dough.gmane.org>
References: <j2bgs2$pf5$1@dough.gmane.org>
	<8ed5a280dcc02566671810bcf7df83a05cb6a35d.1313459746.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:45992 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337Ab1HPMa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 08:30:57 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QtInH-0006Lj-Ns
	for netdev@vger.kernel.org; Tue, 16 Aug 2011 14:30:55 +0200
Received: from 60.160.69.172 ([60.160.69.172])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2011 14:30:55 +0200
Received: from xiyou.wangcong by 60.160.69.172 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2011 14:30:55 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Aug 2011 09:57:35 +0800, Weiping Pan wrote:

> Eduard Sinelnikov (eduard.sinelnikov@gmail.com) found that if we change
> bonding mode from active backup to round robin, some slaves are still
> keeping "backup", and won't transmit packets.
> 
> As Jay Vosburgh(fubar@us.ibm.com) pointed out that we can work around
> that by removing the bond_is_active_slave() check, because the "backup"
> flag is only meaningful for active backup mode.
> 
> But if we just simply ignore the bond_is_active_slave() check, the
> transmission will work fine, but we can't maintain the correct value of
> "backup" flag for each slaves, though it is meaningless for other mode
> than active backup.
> 
> I'd like to reset "backup" and "inactive" flag in bond_open, thus we can
> keep the correct value of them.
> 
> As for bond_is_active_slave(), I'd like to prepare another patch to
> handle it.
> 
> V2:
> Use C style comment.
> Move read_lock(&bond->curr_slave_lock). Replace restore with reset, for
> active backup mode, it means "restore", but for other modes, it means
> "reset".
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.

