From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: add its own Kconfig
Date: Tue, 15 Jul 2014 18:10:56 -0700 (PDT)
Message-ID: <20140715.181056.2116924949727575928.davem@davemloft.net>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbaGPBK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 21:10:57 -0400
In-Reply-To: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Tue, 15 Jul 2014 12:15:39 +0200

> Currently to change some built-in defaults it's necessary to change the
> code, and to maintain these patches on each update.
> 
> Create a bonding's Kconfig to make it possible to configure them at build
> time.

There is really no reason these values can't be set at run time, and that
is my only, but firm, objection to this patch series.

For the per-slave things, make new netlink attributes that can be provided
when the slave is added, using the existing default if not specified.

This means the fixed sized arrays involved here need to become
dynamically allocated.
