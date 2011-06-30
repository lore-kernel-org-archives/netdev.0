From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
 config to ethtool.
Date: Thu, 30 Jun 2011 19:06:19 +0100
Message-ID: <1309457179.2701.6.camel@bwh-desktop>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
	 <20110616.233354.508986372720173787.davem@davemloft.net>
	 <EDC0E76513226749BFBC9C3FB031318F016EEF8A6E@orsmsx508.amr.corp.intel.com>
	 <20110617.145420.866989290749857501.davem@davemloft.net>
	 <EDC0E76513226749BFBC9C3FB031318F016F501D8D@orsmsx508.amr.corp.intel.com>
	 <1308677893.2743.24.camel@bwh-desktop>
	 <EDC0E76513226749BFBC9C3FB031318F016F8D2A76@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36839 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab1F3SGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 14:06:22 -0400
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F016F8D2A76@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-30 at 10:52 -0700, Wyborny, Carolyn wrote:
[...]
> >You may wish to propose a new command structure that covers both IRQ and
> >DMA moderation.  They seem to be related, since DMA cannot be delayed
> >longer than the corresponding IRQ.  We are currently lacking a way to
> >specify different IRQ moderation for multiqueue devices where the queues
> >are not all used in the same way.
> >
> >Ben.
> >
> >--
> >Ben Hutchings, Senior Software Engineer, Solarflare
> >Not speaking for my employer; that's the marketing department's job.
> >They asked us to note that Solarflare product names are trademarked.
> 
> I will try to do this.  Confirming you are suggesting a replacement or
> an alternate for the current -c/-C coalesce settings with perhaps some
> room reserved for some future coalescing type features and enable
> settings per queue?
[...]

Yes.  I'm not insisting that you must do this instead of just defining
the operations for DMA coalescing, but it would be helpful.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

