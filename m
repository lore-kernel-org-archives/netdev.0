From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/17] net/iucv: Add missing spin_unlock
Date: Wed, 26 May 2010 21:10:08 -0700 (PDT)
Message-ID: <20100526.211008.116373263.davem@davemloft.net>
References: <Pine.LNX.4.64.1005261756330.23743@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ursula.braun@de.ibm.com, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751203Ab0E0EJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 00:09:58 -0400
In-Reply-To: <Pine.LNX.4.64.1005261756330.23743@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Wed, 26 May 2010 17:56:48 +0200 (CEST)

> Add a spin_unlock missing on the error path.  There seems like no reason
> why the lock should continue to be held if the kzalloc fail.

Applied, thanks.
