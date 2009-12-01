From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Update embedded copy of ethtool.h from kernel 2.6.30
Date: Tue, 01 Dec 2009 15:52:34 +0000
Message-ID: <1259682754.2831.11.camel@achroite.uk.solarflarecom.com>
References: <20091201151750.GG5694@axis.com>
	 <1259680878.2831.3.camel@achroite.uk.solarflarecom.com>
	 <20091201154246.GH5694@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Jesper Nilsson <Jesper.Nilsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20241 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZLAPwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 10:52:35 -0500
In-Reply-To: <20091201154246.GH5694@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-01 at 16:42 +0100, Jesper Nilsson wrote:
> On Tue, Dec 01, 2009 at 04:21:18PM +0100, Ben Hutchings wrote:
> > On Tue, 2009-12-01 at 16:17 +0100, Jesper Nilsson wrote:
[...]
> > > This size mismatch lead to the ethtool_cmd struct being written
> > > as 44 bytes in the kernel, but only 43 bytes allocated on stack,
> > > overwriting one byte in the stack frame.
> > > 
> > > Update the ethtool copy of the definition to match the 2.6.30 kernel.
> > [...]
> > 
> > This has already been done.
> 
> Ah? Could someone point me to the correct git-tree for ethtool then?
> I've been using http://www.kernel.org/pub/scm/network/ethtool/ethtool.git
> which still has this problem...

That's the correct repository.  It is possible that the extra static
information needed to serve it over HTTP is not up-to-date.  Try using
git protocol instead?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

