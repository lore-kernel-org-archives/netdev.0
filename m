From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Fri, 23 Nov 2007 11:29:25 +1100
Message-ID: <200711231129.25982.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711221456.22297.rusty@rustcorp.com.au> <200711221246.23994.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48487 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbXKWAeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 19:34:12 -0500
In-Reply-To: <200711221246.23994.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 November 2007 22:46:23 Andi Kleen wrote:
> On Thursday 22 November 2007 04:56, Rusty Russell wrote:
> >     This is an interesting idea, thanks for the code!  My only question
> > is whether we can get most of this benefit by dropping the indirection of
> > namespaces and have something like "EXPORT_SYMBOL_TO(sym, modname)"?  It
> > doesn't work so well for exporting to a group of modules, but that seems
> > a reasonable line to draw anyway.
>
> That would explode quickly already even for my example "inet" namespace.
> It already has several modules.  I don't think so much duplication would be
> a good idea.

Yes, and if a symbol is already used by multiple modules, it's generically 
useful.  And if so, why restrict it to in-tree modules?

If your real intent is to bias against out-of-tree modules, let's just 
generate a list of in-tree module names, and restrict some or all exports to 
that set.

Rusty.
