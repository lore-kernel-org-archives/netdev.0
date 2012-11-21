From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6] be2net: Bonding driver does not considerthe
 gso_max_size setting of slaves.
Date: Wed, 21 Nov 2012 12:32:31 +0000
Message-ID: <1353501151.19537.13.camel@deadeye.wl.decadent.org.uk>
References: <da008f0e-76b7-4f34-aa9d-511fe8ce47ac@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <sarveshwar.bandi@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33381 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab2KUMci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:32:38 -0500
In-Reply-To: <da008f0e-76b7-4f34-aa9d-511fe8ce47ac@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 16:37 +0530, sarveshwar.bandi@emulex.com wrote:
> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Patch sets the lowest non-zero gso_max_size value of the slaves during enslave
> and detach.
[...]

The same should be done for gso_max_segs, I think.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
