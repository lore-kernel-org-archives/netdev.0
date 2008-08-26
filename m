From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 0/15] netdevice: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Tue, 26 Aug 2008 18:12:39 +0800
Message-ID: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61506 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752176AbYHZKPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 06:15:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches will convert directly reference of netdev->priv to netdev_priv().

- Patch 1/15 is the safe convert which I believe will not make "after converted " worse
than "before converted".

- Patches 2-14 need comments. Since the value of netdev->priv is changed in drivers
and I use netdev->ml_priv to replace netdev->priv.

