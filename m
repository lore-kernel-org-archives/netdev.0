From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/cris/eth_v10.c:1715:2: error: too many arguments
 to function 'e100rxtx_interrupt'
Date: Wed, 03 Oct 2012 14:40:40 -0400 (EDT)
Message-ID: <20121003.144040.1719867946304137902.davem@davemloft.net>
References: <20120928130608.GA5158@localhost>
	<20121003104652.GK1390@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
To: jesper.nilsson@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab2JCSkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 14:40:42 -0400
In-Reply-To: <20121003104652.GK1390@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Nilsson <jesper.nilsson@axis.com>
Date: Wed, 3 Oct 2012 12:46:52 +0200

> On Fri, Sep 28, 2012 at 03:06:08PM +0200, Fengguang Wu wrote:
>> Hi Jesper,
> 
> Hi!
> 
>> FYI, a rather old build bug that's introduced by
>> 
>> bafef0a cris build fixes: update eth_v10.c ethernet driver
>> 
>> All error/warnings:
>> 
>> drivers/net/cris/eth_v10.c: In function 'e100_netpoll':
>> drivers/net/cris/eth_v10.c:1715:2: error: too many arguments to function 'e100rxtx_interrupt'
>> drivers/net/cris/eth_v10.c:1131:1: note: declared here
> 
> Yep, I can't figure out why the followup patches never reached mainline,
> but we have fixes for exactly that in our in-house tree.
> I'll push some move patches after this merge window.

It's a bug fix, even worse a build fix, why want until after the merge
window?
