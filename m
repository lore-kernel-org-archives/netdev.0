From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
 config to ethtool.
Date: Tue, 21 Jun 2011 18:38:13 +0100
Message-ID: <1308677893.2743.24.camel@bwh-desktop>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
	 <20110616.233354.508986372720173787.davem@davemloft.net>
	 <EDC0E76513226749BFBC9C3FB031318F016EEF8A6E@orsmsx508.amr.corp.intel.com>
	 <20110617.145420.866989290749857501.davem@davemloft.net>
	 <EDC0E76513226749BFBC9C3FB031318F016F501D8D@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5824 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756771Ab1FURiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 13:38:16 -0400
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F016F501D8D@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-21 at 10:23 -0700, Wyborny, Carolyn wrote:
> 
> >-----Original Message-----
> >From: David Miller [mailto:davem@davemloft.net]
> >Sent: Friday, June 17, 2011 11:54 AM
> >To: Wyborny, Carolyn
> >Cc: netdev@vger.kernel.org; bhutchings@solarflare.com
> >Subject: Re: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
> >config to ethtool.
> >
> >From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
> >Date: Fri, 17 Jun 2011 08:50:11 -0700
> >
> >> I will add a fuller description of the feature in my updated patch.
> >> I thought the feature was more well known. Quick description is that
> >> it's a power saving feature that causes the adapter to coalesce its
> >> DMA writes at low traffic times to save power on the platform by
> >> reducing wakeups.  The parameter is intended as a simple u32 value,
> >> not just an on or off, but also to allow a variety of configuration
> >> by adapter vendors, with validation of the input on the driver side.
> >> Since I left out the implementation in my patch, this wasn't clear.
> >> I will also fix this in my next submission.
> >
> >The value cannot have adapter specific meaning, you must define it
> >precisely and in a generic manner, such that the user can specify the
> >same setting across different card types.
> 
> Ok, good point.  I will refine the definition of the parameter in the
> next submission, once the dust clears on the major revisions in
> progress.

You may wish to propose a new command structure that covers both IRQ and
DMA moderation.  They seem to be related, since DMA cannot be delayed
longer than the corresponding IRQ.  We are currently lacking a way to
specify different IRQ moderation for multiqueue devices where the queues
are not all used in the same way.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

