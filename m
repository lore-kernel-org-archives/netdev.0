From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 11:05:45 +0000
Message-ID: <20071122110545.GA4552@infradead.org>
References: <20071122343.446909000@suse.de> <200711221456.22297.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38575 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbXKVLFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 06:05:49 -0500
Content-Disposition: inline
In-Reply-To: <200711221456.22297.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 22, 2007 at 02:56:22PM +1100, Rusty Russell wrote:
>     This is an interesting idea, thanks for the code!  My only question is 
> whether we can get most of this benefit by dropping the indirection of 
> namespaces and have something like "EXPORT_SYMBOL_TO(sym, modname)"?  It
> doesn't work so well for exporting to a group of modules, but that seems
> a reasonable line to draw anyway.

I'd say exporting to a group of modules is the main use case.  E.g. in
scsi there would be symbols exported to transport class modules only
or lots of the vfs_ symbols would be exported only to stackable filesystems
or nfsd.

