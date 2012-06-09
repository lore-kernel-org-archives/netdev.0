From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetpeer: fix build failed when IPV6 not enabled
Date: Fri, 08 Jun 2012 22:20:13 -0700 (PDT)
Message-ID: <20120608.222013.1938519972999084819.davem@davemloft.net>
References: <1339207973-11479-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	wfg@linux.intel.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab2FIFUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 01:20:14 -0400
In-Reply-To: <1339207973-11479-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Sat, 9 Jun 2012 10:12:53 +0800

> fix this by adding #if IS_ENABLED(CONFIG_IPV6)

There is not a single UGLY ifdef in inetpeer.c, and I am not going to
allow you to start crapping it up with ifdefs now.

We support ipv6 just fine without ifdefs before your network namespace
changes, so you need to find a way to continue dong so afterwards.
