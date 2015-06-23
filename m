From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v3] bonding: Display LACP info only to
 CAP_NET_ADMIN capable user
Date: Tue, 23 Jun 2015 03:12:38 -0700 (PDT)
Message-ID: <20150623.031238.1963531649761745747.davem@davemloft.net>
References: <1434652254-17510-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, netdev@vger.kernel.org
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbFWKAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 06:00:50 -0400
In-Reply-To: <1434652254-17510-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Thu, 18 Jun 2015 11:30:54 -0700

> Actor and Partner details can be accessed via proc-fs, sys-fs
> entries or netlink interface. These interfaces are world readable
> at this moment. The earlier patch-series made the LACP communication
> secure to avoid nuisance attack from within the same L2 domain but
> it did not prevent "someone unprivileged" looking at that information
> on host and perform the same act.
> 
> This patch essentially avoids spitting those entries if the user
> in question does not have enough privileges.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
