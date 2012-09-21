From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Ignore spurious UE indication from NIC
Date: Fri, 21 Sep 2012 15:04:13 -0400 (EDT)
Message-ID: <20120921.150413.2303624982785706643.davem@davemloft.net>
References: <20120921163620.GA6147@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659Ab2IUTEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:04:15 -0400
In-Reply-To: <20120921163620.GA6147@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Fri, 21 Sep 2012 11:36:20 -0500

> Ignore spurious UE indication seen on some platforms.
> Consider the error as un-recoverable only when the bits
> stay high during second sampling.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Treating uncorrectable errors as spurious seems like an invitation
for hard to track down data corruption to me.

You'll need to come up with a more sophisticated test for
spurious other than "happens more than once" before I'm willing
to subject the entire world to this kind of potential problem.
