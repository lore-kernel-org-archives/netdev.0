From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_cubic: faster cube root
Date: Wed, 07 Mar 2007 11:33:03 -0800 (PST)
Message-ID: <20070307.113303.04008211.davem@davemloft.net>
References: <20070306144706.4585c079@freekitty>
	<20070306.202052.03980320.davem@davemloft.net>
	<20070307121246.GA7728@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, rkuhn@e18.physik.tu-muenchen.de,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992493AbXCGTdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 14:33:06 -0500
In-Reply-To: <20070307121246.GA7728@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 7 Mar 2007 13:12:46 +0100

> Well that still needs the ugly div64_64 function. At least my goal was to 
> eliminate that, not make it faster (I don't see any evidence this function 
> is particularly performance critical). You prefer to keep div64_64? 

I really have no issues with it.
