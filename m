From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: enable features before registering the
 driver
Date: Mon, 08 Apr 2013 12:16:04 -0400 (EDT)
Message-ID: <20130408.121604.421731991206410747.davem@davemloft.net>
References: <20130406184701.GA16142@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757837Ab3DHQQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:16:07 -0400
In-Reply-To: <20130406184701.GA16142@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Sat, 6 Apr 2013 20:47:01 +0200

> Hi,
> 
> I noticed that mvneta's tx-csum/sg were off until disabled then
> enabled, which led me to think that something was not made in the
> correct sequence. And indeed, setting the dev features _before_
> registering the device works much better :-)
> 
> This patch is for master but may be backported to 3.8-stable as well,
> which is where I first experienced the issue.

Please don't post patches like this, you make extra work for the
maintainer by having to edit out this commentary.

You put such commentary after the "---" seperator the delineates
your commit message in the email body, not before.

Anyways, applied.
