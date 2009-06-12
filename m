From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ntohs() misuse
Date: Thu, 11 Jun 2009 17:23:32 -0700 (PDT)
Message-ID: <20090611.172332.164871596.davem@davemloft.net>
References: <4A3159A3.1070504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51899
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752103AbZFLAX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:23:29 -0400
In-Reply-To: <4A3159A3.1070504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 11 Jun 2009 21:23:15 +0200

> Some drivers incorrectly use ntohs() instead of htons()
> 
> A cleanup as htons() returns same result than ntohs(),
> but better to use the proper one.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
