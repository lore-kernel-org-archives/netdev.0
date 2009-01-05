From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enc28j60: fix RX buffer overflow
Date: Sun, 04 Jan 2009 16:23:19 -0800 (PST)
Message-ID: <20090104.162319.207306783.davem@davemloft.net>
References: <20081230135539.GA10015@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lanconelli.claudio@eptar.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52396
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750964AbZAEAXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 19:23:16 -0500
In-Reply-To: <20081230135539.GA10015@diamond.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Tue, 30 Dec 2008 15:55:39 +0200

> The enc28j60 driver doesn't check whether the length of the packet as reported 
> by the hardware fits into the preallocated buffer. When stressed, the hardware 
> may report insanely large packets even tough the "Receive OK" bit is set. Fix 
> this.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied, thanks.
