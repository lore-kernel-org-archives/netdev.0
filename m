From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Fri, 23 Nov 2007 11:25:11 +1100
Message-ID: <200711231125.12832.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711221456.22297.rusty@rustcorp.com.au> <20071122110545.GA4552@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53852 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060AbXKWAe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 19:34:58 -0500
In-Reply-To: <20071122110545.GA4552@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 November 2007 22:05:45 Christoph Hellwig wrote:
> On Thu, Nov 22, 2007 at 02:56:22PM +1100, Rusty Russell wrote:
> >     This is an interesting idea, thanks for the code!  My only question
> > is whether we can get most of this benefit by dropping the indirection of
> > namespaces and have something like "EXPORT_SYMBOL_TO(sym, modname)"?  It
> > doesn't work so well for exporting to a group of modules, but that seems
> > a reasonable line to draw anyway.
>
> I'd say exporting to a group of modules is the main use case.  E.g. in
> scsi there would be symbols exported to transport class modules only
> or lots of the vfs_ symbols would be exported only to stackable filesystems
> or nfsd.

That's my point.  If there's a whole class of modules which can use a symbol, 
why are we ruling out external modules?  If that's what you want, why not 
have a list of permitted modules compiled into the kernel and allow no 
others?

Cheers,
Rusty.
