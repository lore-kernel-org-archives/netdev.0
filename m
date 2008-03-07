From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Thu, 06 Mar 2008 23:19:47 -0800 (PST)
Message-ID: <20080306.231947.135681188.davem@davemloft.net>
References: <20080305213727.35f46f2f.kazunori@miyazawa.org>
	<20080305.134020.05696990.davem@davemloft.net>
	<47D0E169.5050006@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750944AbYCGHTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 02:19:52 -0500
In-Reply-To: <47D0E169.5050006@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 07 Mar 2008 15:32:09 +0900

> David Miller wrote:
> > I also wonder if the PF_KEY limitation really exists.  For example we
> > will set x->sel.family etc. from the SADB_EXT_ADDRESS_PROXY attribute
> > if present.
> > 
> 
> Yes, we have SADB_EXT_ADDRESS_PROXY. But it is not enough, I think.
> xfrm_selector has both src and dst so that we need some way to
> specify the address is src or dst.
> 
> from RFC2367

Thank you for this information.

> > Finally, if the determination can be made in the data path, it
> > by definition could be made during rule insertion which is much
> > more efficient and appropriate.
> 
> I agree with you.

I am sure there is a simple solution to this problem somewhere,
it is just hiding :-)

Anyways, since I will be in Japan we can discuss alternate
implementation schemes.

Thank you for working on this problem.
