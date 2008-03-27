From: David Miller <davem@davemloft.net>
Subject: Re: [ESP]: Ensure IV is in linear part of the skb to avoid BUG()
 due to OOB access
Date: Thu, 27 Mar 2008 16:09:48 -0700 (PDT)
Message-ID: <20080327.160948.19403357.davem@davemloft.net>
References: <20080327225842.GX20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751548AbYC0XJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 19:09:48 -0400
In-Reply-To: <20080327225842.GX20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Mar 2008 23:58:42 +0100

> ESP does not account for the IV size when calling pskb_may_pull() to
> ensure everything it accesses directly is within the linear part of a
> potential fragment. This results in a BUG() being triggered when the
> both the IPv4 and IPv6 ESP stack is fed with an skb where the first
> fragment ends between the end of the esp header and the end of the IV.
> 
> This bug was found by Dirk Nehring <dnehring@gmx.net> .
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.

Thanks for not letting this fix fall through the cracks.
