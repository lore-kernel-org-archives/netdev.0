From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 4/6] mlxsw: core: Implement temperature
 hwmon interface
Date: Wed, 02 Dec 2015 18:37:58 -0500 (EST)
Message-ID: <20151202.183758.91764299340813651.davem@davemloft.net>
References: <20151202222551.GP2355@nanopsycho.orion>
	<20151202.172847.1855287186918935450.davem@davemloft.net>
	<20151202223531.GQ2355@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerlitz.or@gmail.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491AbbLBXiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 18:38:02 -0500
In-Reply-To: <20151202223531.GQ2355@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 2 Dec 2015 23:35:31 +0100

> Why to continue to work if we know that we are making things wrong
> (incorrect structure initialization in this case) ? What am I missing?

The user might be able to continue to have connectivity and
report the problem.

BUG_ON() is really a hard hammer.
