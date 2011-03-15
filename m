From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Tue, 15 Mar 2011 07:09:36 +0000
Message-ID: <1300172976.32696.42.camel@localhost.localdomain>
References: <1300131040.32696.23.camel@localhost.localdomain>
	 <20110314.132355.226777213.davem@davemloft.net>
	 <1300141060.32696.36.camel@localhost.localdomain>
	 <20110314.152255.68135182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29509 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223Ab1COHJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 03:09:39 -0400
In-Reply-To: <20110314.152255.68135182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-14 at 22:22 +0000, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Date: Mon, 14 Mar 2011 22:17:40 +0000
> 
> > Would you consider a commit patch which imports the baseline driver as
> > is from xen.git (this builds and is functional but needed clean up)
> > followed by the cleanup series? I made sure the cleanup part builds and
> > works at each step as I went (but I will run through it again to be
> > sure).
> > 
> > There is real value (to me at least) in keeping the cleanup separate and
> > being able to (even manually) associate the first upstream commit with
> > an equivalent point in the historical code.
> 
> Do you have any idea what that thing is going to do for poor souls trying
> to bisect?
> 
> GIT is going to hop in and out of your line of development for any GIT
> bisect that traverses any period of time in which those driver commits
> exists.
> 
> It's too messy.

It's exactly the same as any other patch series in this respect though,
isn't it?

But... I'd forgotten that up until "xen: netback: Make dependency on
PageForeign conditional" I was running with a local non-upstreamable
branch containing the PageForeign infrastructure merged which I removed
once I removed the PageForeign dependency was gone, so the series isn't
actually fully buildable upstream like I thought.

So I'll resend a single patch version of the driver today.

> You can keep your tree online somewhere to publish the history, just
> like we do for the old bitkeeper import and similar.

Sure.

Ian.

