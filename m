From: David Miller <davem@davemloft.net>
Subject: Re: Comments requested: Long options and MD5 options
Date: Wed, 18 Jun 2008 16:36:51 -0700 (PDT)
Message-ID: <20080618.163651.50869440.davem@davemloft.net>
References: <396556a20806181239q30024b8bv551f76a890befb0e@mail.gmail.com>
	<20080618.150104.147203818.davem@davemloft.net>
	<396556a20805301217k293e5718h6bbf02bfe0683145@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754753AbYFRXgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 19:36:50 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683145@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Wed, 18 Jun 2008 16:24:33 -0700

> > The retransmit timeout timer has to fire eventually, and when
> > that happens we should clear all of our SACK state.
> 
> Ok, that's good at least. There were other variables in my test that could have
> screwed that up.
> 
> Attached is a patch which pulls the options logic together into a single
> function of SYN/SYNACK and one for established. At the moment, it chooses
> SACK over timestamps for MD5 connections, but it's very easy to change. (And
> that's the point of this patch - the logic isn't spread out)
> 
> Not signed off, because I want to do more testing, and to sleep on it first,
> but pretty close to final.

Thanks for doing this work, I'll have a closer look at this
patch later this evening.
