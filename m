From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] sunvnet: Add ethtool support for netdev
 stastics
Date: Thu, 14 Apr 2016 21:09:09 -0400 (EDT)
Message-ID: <20160414.210909.941648560105026442.davem@davemloft.net>
References: <1460477959-185461-1-git-send-email-atish.patra@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aaron.young@oracle.com,
	sowmini.varadhan@oracle.com
To: atish.patra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbcDOBJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 21:09:12 -0400
In-Reply-To: <1460477959-185461-1-git-send-email-atish.patra@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atish Patra <atish.patra@oracle.com>
Date: Tue, 12 Apr 2016 09:19:19 -0700

> Currently, sunvnet does not support statstics display
> via sysfs entry using ethtool.

ethtool is not for the already provided network device statistics.

It is for device specific statistic extensions, and acts as an
addition to the existing generic networking device stats, rather
than duplicating what already exists.
