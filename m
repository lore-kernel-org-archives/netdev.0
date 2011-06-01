From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vlan: fix typo in vlan_dev_hard_start_xmit()
Date: Wed, 1 Jun 2011 13:54:42 +0000 (UTC)
Message-ID: <is5gb2$1h6$2@dough.gmane.org>
References: <4DE5FDFF.4000208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60248 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180Ab1FANzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 09:55:18 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QRlt5-0005rT-0B
	for netdev@vger.kernel.org; Wed, 01 Jun 2011 15:55:07 +0200
Received: from 222-151-096-013.jp.fiberbit.net ([222.151.96.13])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 15:55:06 +0200
Received: from xiyou.wangcong by 222-151-096-013.jp.fiberbit.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 15:55:06 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Jun 2011 16:53:19 +0800, Wei Yongjun wrote:

> commit 4af429d29b341bb1735f04c2fb960178ed5d52e7 (vlan: lockless transmit
> path) have a typo in vlan_dev_hard_start_xmit(), using
> u64_stats_update_begin() to end the stat update, it should be
> u64_stats_update_end().
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Yup, good catch!

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

