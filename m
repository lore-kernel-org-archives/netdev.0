From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 18:16:00 -0500 (EST)
Message-ID: <20121113.181600.667479923208656972.davem@davemloft.net>
References: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
	<20121113.165300.1149843648625252626.davem@davemloft.net>
	<1352845788.6276.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924Ab2KMXQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 18:16:04 -0500
In-Reply-To: <1352845788.6276.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 13 Nov 2012 14:29:48 -0800

> We need to have VLAN tags inserted to packets using that interface.
> The VID is dynamically discovered by application.  How do suggest we
> do that if we don't use 8021q?

Ok.  So what's the reason that the VLAN device isn't given a
valid MAC address, for example why not use the SAN one?
