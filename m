From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] v3.12-rc5-139-gbdeeab6 assertion failed at
 drivers/net/bonding/bond_main.c (3398)
Date: Sat, 19 Oct 2013 18:44:11 -0400 (EDT)
Message-ID: <20131019.184411.2017497732906948451.davem@davemloft.net>
References: <20131019202702.GA8354@glanzmann.de>
	<20131019205222.GA18874@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas@glanzmann.de, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, nikolay@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab3JSWoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:44:13 -0400
In-Reply-To: <20131019205222.GA18874@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sat, 19 Oct 2013 22:52:22 +0200

> Fixed in commit b32418705107265dfca5edfe2b547643e53a732e ("bonding:
> RCUify
> bond_set_rx_mode()") net-next. It should get into mainline soon.

If it's in net-next it's not going into mainline soon.

A change that fixes a bug should go into 'net', not 'net-next'.
