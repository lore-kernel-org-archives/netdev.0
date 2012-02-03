From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V4 08/13] xenbus_client: extend interface to support
 mapping / unmapping of multi page ring.
Date: Fri, 3 Feb 2012 12:35:43 -0500
Message-ID: <20120203173543.GA2391@phenom.dumpdata.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
 <1328201363-13915-9-git-send-email-wei.liu2@citrix.com>
 <20120203165516.GA20005@phenom.dumpdata.com>
 <1328289625.7388.38.camel@leeds.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:64524 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753592Ab2BCRih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 12:38:37 -0500
Content-Disposition: inline
In-Reply-To: <1328289625.7388.38.camel@leeds.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2012 at 05:20:25PM +0000, Wei Liu wrote:
> On Fri, 2012-02-03 at 16:55 +0000, Konrad Rzeszutek Wilk wrote:
> > On Thu, Feb 02, 2012 at 04:49:18PM +0000, Wei Liu wrote:
> > > 
> > 
> > So this does the job but with this patch you introduce a compile bisection
> > bug, which is a not good. The way around is that in this patch you also
> > introduce temporary scaffolding so that the drivers can build. Something
> > as simple as an function that calls the new version, but has the right
> > arguments. Then the next patch (the one that actually does change
> > the backends, will back that wrapper out).
> > 
> 
> How about squashing these two patches. The changes in backends are
> trivial.

That could be done as well.
