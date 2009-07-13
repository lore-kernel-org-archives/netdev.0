From: David Miller <davem@davemloft.net>
Subject: Re: use after free bug in socket code
Date: Mon, 13 Jul 2009 10:54:25 -0700 (PDT)
Message-ID: <20090713.105425.159427879.davem@davemloft.net>
References: <20090709154533.GA27413@gondor.apana.org.au>
	<19035.23045.386506.297464@ipc1.ka-ro>
	<4A5B730B.8090902@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LW@KARO-electronics.de, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	urs@isnogud.escape.de
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52995
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753639AbZGMRyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 13:54:21 -0400
In-Reply-To: <4A5B730B.8090902@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Mon, 13 Jul 2009 19:46:51 +0200

> But from what i was able to get from browsing similar code in the Kernel that
> at least sock_orphan() is called in the appropriate socket release functions,
> which is indeed not done by the mentioned PF_CAN protocols right now.
> 
> I assume you already tested this patch (at least with CAN_RAW) successfully,
> right?
> 
> If so, i would have no objections to add my Acked-by to these changes.
> 
> Would you like to prepare a proper patch and post it on netdev?

Indeed, please do make such a formal submission once properly tested.

Thanks!
