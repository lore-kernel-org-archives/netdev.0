From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Mon, 23 Jul 2007 19:06:42 +0200
Message-ID: <20070723170642.GA13771@one.firstfloor.org>
References: <20070720.223129.59470764.davem@davemloft.net> <p73lkd9vqfr.fsf@bingen.suse.de> <20070723105822.3a9fa152@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41061 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755764AbXGWRGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 13:06:46 -0400
Content-Disposition: inline
In-Reply-To: <20070723105822.3a9fa152@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 23, 2007 at 10:58:22AM +0100, Stephen Hemminger wrote:
> On 21 Jul 2007 15:26:00 +0200
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > David Miller <davem@davemloft.net> writes:
> > > 
> > > Good candidates for taking advantage of multi-napi are:
> > > 
> > > 1) e1000
> > > 2) ucc_geth
> > > 3) ehea
> > > 4) sunvnet
> > 
> > s2io.c
> 
> sky2.c could use it because of issues with dual-port that share
> one napi for status.

Sorry, I didn't parse the sentence. Did you mean "couldn't use it" ...? 
Also can you elaborate why it shouldn't work?

-Andi
