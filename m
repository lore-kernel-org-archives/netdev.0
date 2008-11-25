From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Make sure BHs are disabled in
 sock_prot_inuse_add()
Date: Tue, 25 Nov 2008 13:53:40 -0800 (PST)
Message-ID: <20081125.135340.188297695.davem@davemloft.net>
References: <492AE30C.70907@cosmosbay.com>
	<492C618B.8090403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57967
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751857AbYKYVxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 16:53:41 -0500
In-Reply-To: <492C618B.8090403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 25 Nov 2008 21:35:23 +0100

> Oh well...
> 
> [PATCH] net: Make sure BHs are disabled in sock_prot_inuse_add()
> 
> prot->destroy is not called with BH disabled. So we must add
> explicit BH disable around call to sock_prot_inuse_add()
> in sctp_destroy_sock()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

At least it was found eventually :)

Applied, thanks Eric.
