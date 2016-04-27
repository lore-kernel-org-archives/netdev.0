From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Wed, 27 Apr 2016 16:23:09 -0400 (EDT)
Message-ID: <20160427.162309.63254917338216507.davem@davemloft.net>
References: <874mamzw5q.fsf@ketchup.mtl.sfl>
	<20160427194932.GF29024@lunn.ch>
	<57211C81.4000903@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	f.fainelli@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	kernel@savoirfairelinux.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbcD0UXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 16:23:11 -0400
In-Reply-To: <57211C81.4000903@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 27 Apr 2016 23:09:37 +0300

> On 04/27/2016 10:49 PM, Andrew Lunn wrote:
> 
>> Please revert this, or fix all the callsites such that ENODEV is not a
>> fatal error.
> 
>    OK, I'll do what DaveM decides.

If you feel confident getting all the ENODEV checks right, please just do
that.

Thanks.
