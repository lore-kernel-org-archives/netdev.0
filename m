From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] net: rename group sysfs entry to
 netdev_group
Date: Wed, 09 Feb 2011 19:16:44 -0800 (PST)
Message-ID: <20110209.191644.193705109.davem@davemloft.net>
References: <20110209.140323.39178091.davem@davemloft.net>
	<20110209.140558.59676278.davem@davemloft.net>
	<4D53536B.2010505@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	therbert@google.com, ebiederm@xmission.com, shemminger@vyatta.com,
	ddvlad@rosedu.org
To: dfeng@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47301
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946Ab1BJDQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 22:16:09 -0500
In-Reply-To: <4D53536B.2010505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaotian Feng <dfeng@redhat.com>
Date: Thu, 10 Feb 2011 10:54:35 +0800

> Subject: [PATCH net-next v2] net: rename group sysfs entry to netdev_group
> 
> commit a512b92 adds sysfs entry for net device group, but
> before this commit, tun also uses group sysfs, so after this
> commit checkin, kernel warns like this:
>     sysfs: cannot create duplicate filename '/devices/virtual/net/vnet0/group'
> 
> Since tun has used this for years, rename sysfs under tun might
> break existing userspace, so rename group sysfs entry for net device
> group is a better choice.
> 
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>

Applied.
