From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Mon, 19 Nov 2007 23:49:43 -0800 (PST)
Message-ID: <20071119.234943.214163033.davem@davemloft.net>
References: <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
	<20071119130610.GB6952@ms2.inr.ac.ru>
	<20071120001607.916f4537.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, the.sator@gmail.com,
	linux-kernel@vger.kernel.org, jmorris@namei.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40785
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759242AbXKTHto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:49:44 -0500
In-Reply-To: <20071120001607.916f4537.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Fink <billfink@mindspring.com>
Date: Tue, 20 Nov 2007 00:16:07 -0500

> On Mon, 19 Nov 2007, Alexey Kuznetsov wrote:
> 
> > 2. What's about your suggestion, I thought about this and I am going to agree.
> > 
> >    Arguments, which convinced me are:
> > 
> >    - arping still works.
> >    - any piece of reasonable software should work.
> >    - if Windows understands DaD (is it really true? I cannot believe)
> >      and it is unhappy about our responce and does not block use
> >      of duplicate address only due to this, we _must_ accomodate ASAP.
> >    - if we do,we have to use 0 protocol address, no choice.
> 
> I agree the target protocol address should be 0 in this case.

Patches, someone :-)
