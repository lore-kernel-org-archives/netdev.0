From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V4 08/13] xenbus_client: extend interface to
 support mapping / unmapping of multi page ring.
Date: Fri, 3 Feb 2012 17:20:25 +0000
Message-ID: <1328289625.7388.38.camel@leeds.uk.xensource.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-9-git-send-email-wei.liu2@citrix.com>
	 <20120203165516.GA20005@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:48021 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757110Ab2BCRUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 12:20:05 -0500
In-Reply-To: <20120203165516.GA20005@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-03 at 16:55 +0000, Konrad Rzeszutek Wilk wrote:
> On Thu, Feb 02, 2012 at 04:49:18PM +0000, Wei Liu wrote:
> > 
> 
> So this does the job but with this patch you introduce a compile bisection
> bug, which is a not good. The way around is that in this patch you also
> introduce temporary scaffolding so that the drivers can build. Something
> as simple as an function that calls the new version, but has the right
> arguments. Then the next patch (the one that actually does change
> the backends, will back that wrapper out).
> 

How about squashing these two patches. The changes in backends are
trivial.


Wei.
