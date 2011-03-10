From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT/PATCH v4] xen network backend driver
Date: Thu, 10 Mar 2011 17:17:17 +0000
Message-ID: <1299777438.2807.0.camel@bwh-desktop>
References: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
	 <20110310091425.3451f7f1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34582 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728Ab1CJRRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 12:17:21 -0500
In-Reply-To: <20110310091425.3451f7f1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-10 at 09:14 -0800, Stephen Hemminger wrote:
> On Thu, 10 Mar 2011 17:02:33 +0000
> Ian Campbell <Ian.Campbell@citrix.com> wrote:
> 
> > +	/* Flags that must not be set in dev->features */
> > +	int features_disabled;
> 
> dev->features is unsigned long, so this mask should be as well.

It's u32 now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

