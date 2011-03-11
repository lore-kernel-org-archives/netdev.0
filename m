From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v4] xen network backend driver
Date: Fri, 11 Mar 2011 10:30:04 +0000
Message-ID: <1299839404.17339.1893.camel@zakaz.uk.xensource.com>
References: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
	 <20110310091425.3451f7f1@nehalam>  <1299777438.2807.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:55677 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab1CKKaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 05:30:06 -0500
In-Reply-To: <1299777438.2807.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-10 at 17:17 +0000, Ben Hutchings wrote:
> On Thu, 2011-03-10 at 09:14 -0800, Stephen Hemminger wrote:
> > On Thu, 10 Mar 2011 17:02:33 +0000
> > Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > 
> > > +	/* Flags that must not be set in dev->features */
> > > +	int features_disabled;
> > 
> > dev->features is unsigned long, so this mask should be as well.
> 
> It's u32 now.

That's in net-next only but I think there's no harm in making it u32 in
my netback branch (which is based on a tree which uses unsigned long).
Then it will be correct when merged.

Alternatively I could pull net-next into my branch but I don't think
that's necessary in this case.

Ian.

