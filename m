From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igmp: check add_grhead() return value
Date: Tue, 06 Feb 2007 14:35:57 -0800 (PST)
Message-ID: <20070206.143557.123974184.davem@davemloft.net>
References: <20070130105701.GA6015@localhost.sw.ru>
	<OF52248A96.35A5CA3C-ON88257273.003E5791-88257273.003F9122@us.ibm.com>
	<20070205150432.GA5961@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: adobriyan@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52053
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752298AbXBFWgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:36:22 -0500
In-Reply-To: <20070205150432.GA5961@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@openvz.org>
Date: Mon, 5 Feb 2007 18:04:33 +0300

> OK, now that we aren't seeing crashes which can be attributed to these
> NULL dereferences any longer.
> --------------------------------------
> add_grhead() allocates memory with GFP_ATOMIC and in at least two places skb
> from it passed to skb_put() without checking.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@openvz.org>

Thanks for the patch and for testing Alexey.

Applied, and I'll push this to -stable too.

Thanks again.
