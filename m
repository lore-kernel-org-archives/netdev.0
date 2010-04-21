From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cleanup: remove two unnecessary exports in
 skbuff.c.
Date: Tue, 20 Apr 2010 19:26:01 -0700 (PDT)
Message-ID: <20100420.192601.109636833.davem@davemloft.net>
References: <l2geb3ff54b1004190250qfe606c28i80dab5f156128f4c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42390
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755076Ab0DUCZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 22:25:56 -0400
In-Reply-To: <l2geb3ff54b1004190250qfe606c28i80dab5f156128f4c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon, 19 Apr 2010 12:50:19 +0300

> There is no need to export skb_under_panic() and skb_over_panic() in
> skbuff.c, since these methods are used only in
> skbuff.c ; this patch removes these two exports.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

If this is indeed the case, you should also mark these functions
'static' and remove the extern declarations of them from
include/linux/skbuff.h

Please make those changes and resubmit your patch (against
net-next-2.6 since that's where it belongs at this point).

Thanks.
