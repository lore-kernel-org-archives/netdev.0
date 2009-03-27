From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix headroom expansion code
Date: Fri, 27 Mar 2009 00:39:26 -0700 (PDT)
Message-ID: <20090327.003926.134928961.davem@davemloft.net>
References: <20090325.172139.142233386.davem@davemloft.net>
	<20090326100856.265f7872@nehalam>
	<2a27d3730903262126v1a0282a5u6c8ee234dff8708d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751857AbZC0Hji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:39:38 -0400
In-Reply-To: <2a27d3730903262126v1a0282a5u6c8ee234dff8708d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Fri, 27 Mar 2009 12:26:33 +0800

> We have legacy devices without the offloading feature.  And we can
> even turn off the IP checksum offloading at runtime.  Your code will
> cause unnecessary realloc for these cases.
> 
> I can propose a new patch to fix the pointer problem and add more
> error handling.

I'm applying Stephen's patch for now, please send any improvements
relative to that.
