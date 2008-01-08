From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Mon, 07 Jan 2008 21:10:18 -0800 (PST)
Message-ID: <20080107.211018.160153013.davem@davemloft.net>
References: <20080108020529.GC16156@one.firstfloor.org>
	<20080107.193700.159646842.davem@davemloft.net>
	<20080108050007.GA25338@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, acme@redhat.com, paul.moore@hp.com,
	latten@us.ibm.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750707AbYAHFKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:10:19 -0500
In-Reply-To: <20080108050007.GA25338@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 8 Jan 2008 06:00:07 +0100

> On Mon, Jan 07, 2008 at 07:37:00PM -0800, David Miller wrote:
> > The vast majority of them are one, two, and three liners.
> 
> % awk '  { line++ } ; /^{/ { total++; start = line } ; /^}/ { len=line-start-3; if (len > 4) l++; if (len >= 10) k++; } ; END { print total, l, l/total, k, k/total }' < include/net/tcp.h
> 68 28 0.411765 20 0.294118
> 
> 41% are over 4 lines, 29% are >= 10 lines.

Take out the comments and whitespace lines, your script is
too simplistic.
