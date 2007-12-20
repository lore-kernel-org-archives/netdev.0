From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove not used code: target hw address (tha)
 definition and assignment in arp_process().
Date: Wed, 19 Dec 2007 23:39:32 -0800 (PST)
Message-ID: <20071219.233932.210886166.davem@davemloft.net>
References: <dac45060712192329v48bcd3td4f16f83ea13ba9e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: markryde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751119AbXLTHji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 02:39:38 -0500
In-Reply-To: <dac45060712192329v48bcd3td4f16f83ea13ba9e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mark Ryden" <markryde@gmail.com>
Date: Thu, 20 Dec 2007 09:29:47 +0200

>   In arp_process() (net/ipv4/arp.c), there is unused code: definition
> and assignment of tha (target hw address ).

Patch applied, thanks.

> Signed-off-by:
> markryde@gmail.com

Please format your signed off line correctly, it should
have read like the following, all on one single line:

Signed-off-by: Mark Ryden <markryde@gmail.com>

Also, your patch was not rooted properly:

--- a/a/net/ipv4/arp.c
+++ b/b/net/ipv4/arp.c

This should have been:

--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c

Please correct these issues for future patch submissions.

Thanks.
