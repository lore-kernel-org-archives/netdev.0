From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH]  fix sierra_net endianess bug
Date: Wed, 14 Mar 2012 19:24:22 +0000
Message-ID: <1331753062.2564.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F60A695.4040601@mt.lv> <m2399bmcfq.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maris Paupe <marisp@mt.lv>, <epasheva@sierrawireless.com>,
	<rfiler@sierrawireless.com>, <netdev@vger.kernel.org>
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40792 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932101Ab2CNTY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 15:24:26 -0400
In-Reply-To: <m2399bmcfq.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 16:26 +0100, Andreas Schwab wrote:
> Maris Paupe <marisp@mt.lv> writes:
> 
> > I have found that sierra_net does not work properly on big-endian
> > systems, it works if bytes are flipped in this particular location.
> 
> That should probably be fixed in sierra_net_get_fw_attr (and the author
> of sierra_net_get_fw_attr should be hit with a cluestick to not use
> kmalloc for allocating a single u16).

You cannot use stack buffers for DMA, which includes all USB I/O.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
