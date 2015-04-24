From: David Miller <davem@davemloft.net>
Subject: Re: Resource usages in Linux drivers
Date: Thu, 23 Apr 2015 20:49:00 -0400 (EDT)
Message-ID: <20150423.204900.151579135360632583.davem@davemloft.net>
References: <5538CB50.3010601@cogentembedded.com>
	<20150423231917.GA16450@electric-eye.fr.zoreil.com>
	<553990EC.1030401@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sergei.shtylyov@cogentembedded.com,
	baijiaju1990@163.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nhorman@tuxdriver.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbbDXAtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 20:49:04 -0400
In-Reply-To: <553990EC.1030401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 23 Apr 2015 17:40:12 -0700

> Well, for one, we could have a device managed register_netdev()
> which cleans up resources in case of failures and calls
> free_netdev() automatically, but is that adding much value?

I don't think it's worth it at all.
