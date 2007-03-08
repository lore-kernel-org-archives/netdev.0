From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_cubic: use 32 bit math
Date: Wed, 07 Mar 2007 19:51:35 -0800 (PST)
Message-ID: <20070307.195135.74749102.davem@davemloft.net>
References: <20070307170731.2b4397e3@freekitty>
	<20070307.185539.48527371.davem@davemloft.net>
	<45EF7EB7.8040806@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbXCHDvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 22:51:37 -0500
In-Reply-To: <45EF7EB7.8040806@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 07 Mar 2007 19:10:47 -0800

> David Miller wrote:
> > What about Willy Tarreau's supposedly even faster variant?
> > Or does this incorporate that set of improvements?
> >   
> That's what this is:
>     x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;

Great, thanks for the clarification.
