From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 4/4] netxen: bridged mode optimizations
Date: Wed, 26 Aug 2009 15:37:58 -0700 (PDT)
Message-ID: <20090826.153758.165069820.davem@davemloft.net>
References: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
	<1251177808-16450-4-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org,
	narender.kumar@qlogic.com
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51673
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754179AbZHZWhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 18:37:45 -0400
In-Reply-To: <1251177808-16450-4-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Mon, 24 Aug 2009 22:23:28 -0700

> From: Narender Kumar <narender.kumar@qlogic.com>
> 
> When the interface is put in bridged mode, destination mac
> addresses are unknown to firmware. So packets take a slow
> path (lower priority) in firmware reducing performance.
> 
> Firmware can cache limited number of remote unicast mac
> addresses for certain interval, if "dynamic mac learning"
> mode is enabled.
> 
> Driver needs to enable this "mac learning" mode in firmware.
> Currently this is done through net device class sysfs entry,
> possibly this can also be done upon netlink notifications to
> from bridge.
> 
> Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
