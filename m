From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Mon, 07 Jan 2008 17:54:58 -0800 (PST)
Message-ID: <20080107.175458.127194310.davem@davemloft.net>
References: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
	<20080105.231658.168081302.davem@davemloft.net>
	<p73sl19qi6o.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, acme@redhat.com, paul.moore@hp.com,
	latten@us.ibm.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40312
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbYAHBy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 20:54:59 -0500
In-Reply-To: <p73sl19qi6o.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 08 Jan 2008 01:23:11 +0100

> David Miller <davem@davemloft.net> writes:
> 
> > Similarly I question just about any inline usage at all in *.c files
> 
> Don't forget the .h files. Especially a lot of stuff in tcp.h should
> be probably in some .c file and not be inline.

I explicitly left them out.

Most of them are abstractions of common 2 or 3 instruction
calculations, and thus should stay inline.
