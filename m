From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc95xx: fix async register writes on big endian
 platforms
Date: Mon, 10 Dec 2012 14:10:20 -0500 (EST)
Message-ID: <20121210.141020.74019636450771218.davem@davemloft.net>
References: <1355137388-2938-1-git-send-email-steve.glendinning@shawell.net>
	<1355137388-2938-2-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab2LJTKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 14:10:21 -0500
In-Reply-To: <1355137388-2938-2-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Mon, 10 Dec 2012 11:03:08 +0000

> This patch fixes a missing endian conversion which results in the
> interface failing to come up on BE platforms.
> 
> It also removes an unnecessary pointer dereference from this
> function.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied.
