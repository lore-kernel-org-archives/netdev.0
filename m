From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: tg3: regression of netdev stats
Date: Fri, 01 Mar 2013 22:21:40 +0900
Message-ID: <878v67xnkr.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com, mchan@broadcom.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:42232 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab3CANkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 08:40:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

f4a46d1f46a8fece34edd2023e054072b02e110d (tg3: Prevent spurious tx
timeout by setting carrier off before tx disable.) seems to add the bug.

On 3.8.1 (I didn't use 3.7.x series), "ifconfig" commands doesn't show
any stats, i.e. all stats are zero. And bisect points the above commit.
In fact, reverting the above patch fixes the regression of netdev stats.

This patch looks like strange, and I'm not sure what this want to do.
Any ideas?

Well, anyway, this is bug report.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
