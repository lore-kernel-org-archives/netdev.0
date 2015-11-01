From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 0/2] ipv4: fix problems from the RTNH_F_LINKDOWN
 introduction
Date: Sun, 01 Nov 2015 16:58:08 -0500 (EST)
Message-ID: <20151101.165808.1012194708058297171.davem@davemloft.net>
References: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbbKAV6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 16:58:11 -0500
In-Reply-To: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Fri, 30 Oct 2015 10:23:32 +0200

> Fix two problems from the change that introduced RTNH_F_LINKDOWN
> flag. The first patch deals with the removal of local route on
> DOWN event. The second patch makes sure the RTNH_F_LINKDOWN
> flag is properly updated on UP event because the DOWN event
> sets it in all cases.

Series applied and queued up for -stable, thanks Julian.
