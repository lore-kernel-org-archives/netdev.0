From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: Fix switch on port type
Date: Tue, 01 Dec 2009 11:11:00 -0500
Message-ID: <4B154014.3030101@garzik.org>
References: <1259683615.2831.16.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45036 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752827AbZLAQLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 11:11:00 -0500
In-Reply-To: <1259683615.2831.16.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2009 11:06 AM, Ben Hutchings wrote:
> The new port type cases in commit 6e0512c 'ethtool: Add Direct Attach
> to the available connector ports' were somehow inserted into the
> switch on duplex type, not on port type.  Move them to the correct
> place.
>
> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
> ---
>   ethtool.c |   12 ++++++------
>   1 files changed, 6 insertions(+), 6 deletions(-)

ouch - one of the downsides of git happily merging away without complaint.

applied



