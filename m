From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 15:26:52 +1100
Message-ID: <200711271526.53065.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711261225.44415.rusty@rustcorp.com.au> <adalk8lsg3z.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43551 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755AbXK0E0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 23:26:53 -0500
In-Reply-To: <adalk8lsg3z.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 November 2007 16:58:08 Roland Dreier wrote:
>  > > I agree that we shouldn't make things too hard for out-of-tree
>  > > modules, but I disagree with your first statement: there clearly is a
>  > > large class of symbols that are used by multiple modules but which are
>  > > not generically useful -- they are only useful by a certain small
>  > > class of modules.
>  >
>  > If it is so clear, you should be able to easily provide examples?
>
> Sure -- Andi's example of symbols required only by TCP congestion
> modules;

Exactly.  Why exactly should someone not write a new TCP congestion module?

> the SCSI internals that Christoph wants to mark

He didn't justify those though, either.

> ; the symbols  exported by my mlx4_core driver (which I admit are
> currently only used 
> by the mlx4_ib driver, but which will also be used by at least the
> ethernet NIC driver for the same hardware).

Right.  So presumably there will only ever be two drivers using this core 
code, so no new users will ever be written?  Now we've found one use case, is 
it worth the complexity of namespaces?  Is it worth the halfway point of 
export-to-module?

What problem will it solve?

> I thought this was 
> already covered repeatedly in the thread and indeed in Andi's code so
> there was no need to repeat it...

No, we've seen the solution and various people applying it.  I'm still trying 
to discover the problem it's solving.

Hope that helps,
Rusty.
