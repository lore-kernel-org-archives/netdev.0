From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] alx: add a simple AR816x/AR817x device driver
Date: Mon, 17 Jun 2013 16:05:24 -0700 (PDT)
Message-ID: <20130617.160524.299285792506397317.davem@davemloft.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	<1371501842-24452-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, js@sig21.net, romieu@fr.zoreil.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab3FQXFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 19:05:25 -0400
In-Reply-To: <1371501842-24452-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 17 Jun 2013 22:44:02 +0200

> This is a very simple driver, based on the original vendor
> driver that Qualcomm/Atheros published/submitted previously,
> but reworked to make the code saner. However, it also lost
> a number of features (TSO/GSO, VLAN acceleration and multi-
> queue support) in the process, as well as debugging support
> features I didn't have any use for. The only thing I left
> is checksum offload.
> 
> More features can obviously be added, but this seemed like
> a good start for having a driver in mainline at all.
> 
> Johannes Stezenbach has verified that the driver works on
> AR8161, I have a AR8171 myself. The E2200 device ID I found
> on github in somebody's repository.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

I've applied this to 'net', thanks Johannes.  There might be some
fixups still needed, but for people who have these devices this
is a huge improvement for them.

Thanks!
