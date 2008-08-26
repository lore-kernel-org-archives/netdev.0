From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 0/15] netdevice: Convert directly reference of
	netdev->priv to netdev_priv()
Date: Tue, 26 Aug 2008 11:46:47 -0400
Message-ID: <1219765607.16297.16.camel@lap75545.ornl.gov>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lap75545.ornl.gov ([160.91.210.54]:38295 "EHLO
	lap75545.ornl.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915AbYHZPq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 11:46:57 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-08-26 at 18:12 +0800, Wang Chen wrote:
> Following patches will convert directly reference of netdev->priv to netdev_priv().
> 
> - Patch 1/15 is the safe convert which I believe will not make "after converted " worse
> than "before converted".

When breaking a big patch into multiple messages, please put a diffstat
for that message above the patch -- and it'd be good to have one in the
introduction message as well. This lets reviewers take a quick glance
and see if code they maintain is affected, rather than having to search
through each message to see what files it touches.

Thanks,
Dave
