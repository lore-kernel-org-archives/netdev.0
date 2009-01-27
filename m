From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix tcp splice length
Date: Mon, 26 Jan 2009 22:14:52 -0800 (PST)
Message-ID: <20090126.221452.157337515.davem@davemloft.net>
References: <200901270512.n0R5CLXB019113@darkside.asicdesigners.com>
	<497EA55A.2050905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org, w@1wt.eu
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbZA0GOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 01:14:55 -0500
In-Reply-To: <497EA55A.2050905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 27 Jan 2009 07:10:34 +0100

> Nice spot Dimitris !
> 
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Ok, I'll apply this.

> This fixes a bug present in previous linux versions (before commit 
> 33966dd0e2f68f26943cd9ee93ec6abbc6547a8e tcp: splice as many packets
>  as possible at once)
>  
> It should be backported as well, changing tss->len by min(tss->len, len) ?

Indeed, I'll queue this up for -stable to remind myself about
this.

Thanks Eric.
