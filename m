From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sfc fix for 2.6.27
Date: Tue, 10 Jun 2008 18:12:57 -0400
Message-ID: <484EFC69.5080708@pobox.com>
References: <20080609182428.GI11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46109 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753793AbYFJWM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:12:59 -0400
In-Reply-To: <20080609182428.GI11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Jeff,
> 
> Please add the following patch to your changes for 2.6.27.
> 
> Ben.
> 
> Ben Hutchings (1):
>   sfc: I2C adapter initialisation fixes
> 
>  drivers/net/sfc/falcon.c |   12 +++---------
>  1 files changed, 3 insertions(+), 9 deletions(-)

You're getting the email subject line a bit wrong.

If it says "[PATCH]", one expects the email to actually contain a patch...

The normal options for including comments are:

1) If it's a single patch, include meta-comments like "for 2.6.27, not 
2.6.26" after the "---" separator.  See Documentation/SubmittingPatches 
for more information.

2) If it's multiple patches, include exposition in a separate email 
numbered zero.  Example subject lines of three emails:

	[PATCH 0/2] sfc: patchset to do cool and nifty stuff

	(summarizes the patchset)

	[PATCH 1/2] sfc: add support for nifty feature bamboozle
	[PATCH 2/2] sfc: remove support for silly feature zappadoo

	(individual patches)

Regards,

	Jeff



