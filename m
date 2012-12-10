From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc75xx: only set mac address once on bind
Date: Mon, 10 Dec 2012 14:10:08 -0500 (EST)
Message-ID: <20121210.141008.1837161608811155049.davem@davemloft.net>
References: <1355137279-2695-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjorn@mork.no, dcbw@redhat.com
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab2LJTKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 14:10:11 -0500
In-Reply-To: <1355137279-2695-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Mon, 10 Dec 2012 11:01:19 +0000

> This patch changes when we decide what the device's MAC address
> is from per ifconfig up to once when the device is connected.
> 
> Without this patch, a manually forced device MAC is overwritten
> on ifconfig down/up.  Also devices that have no EEPROM are
> assigned a new random address on ifconfig down/up instead of
> persisting the same one.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
> Reported-by: Robert Cunningham <rcunningham@nsmsurveillance.com>

Applied.
