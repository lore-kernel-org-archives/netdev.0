From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor data
Date: Fri, 22 Jun 2012 17:26:51 -0700 (PDT)
Message-ID: <20120622.172651.932738000786251092.davem@davemloft.net>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
	<1340237192-30052-2-git-send-email-mchan@broadcom.com>
	<1340237192-30052-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932467Ab2FWA0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 20:26:52 -0400
In-Reply-To: <1340237192-30052-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 20 Jun 2012 17:06:32 -0700

> Some tg3 devices have management firmware that can export data such as
> temperature and other real time diagnostics data.  Export this data to
> sysfs so that userspace can access this information.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I do not agree that sysfs is the appropriate place to export binary
data.
