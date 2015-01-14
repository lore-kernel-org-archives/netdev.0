From: David Miller <davem@davemloft.net>
Subject: Re: Why is bridge's sysfs values in 1/100 of second?
Date: Tue, 13 Jan 2015 21:53:15 -0500 (EST)
Message-ID: <20150113.215315.1497532830850392530.davem@davemloft.net>
References: <54B5D5DA.5080008@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbbANC64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 21:58:56 -0500
In-Reply-To: <54B5D5DA.5080008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 13 Jan 2015 18:35:06 -0800

> Are the units supposed to be 1/100 of a second, or is that just some
> luck depending on HZ?

More specifically, it's "USER_HZ" which unlike HZ is unchanging.
