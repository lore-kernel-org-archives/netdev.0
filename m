From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 1/2] Revert "Fix reporting of VLAN tag offload
 flags on Linux < 2.6.37"
Date: Tue, 1 Oct 2013 16:35:44 +0100
Message-ID: <1380641744.1939.0.camel@bwh-desktop.uk.level5networks.com>
References: <1379978698.2485.85.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62669 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab3JAPfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 11:35:51 -0400
In-Reply-To: <1379978698.2485.85.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 00:24 +0100, Ben Hutchings wrote:
> This reverts commit 1cddbe64cfc66b58988c85086d6df3a77c0c61a5.
> It causes 'ethtool -K' to pass the VLAN tag offload flags to
> ETHTOOL_SFLAGS when they are not supported and will be rejected.
> ---
>  ethtool.c | 41 -----------------------------------------
>  1 file changed, 41 deletions(-)

I've now applied this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
