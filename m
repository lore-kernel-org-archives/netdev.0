From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] sfc: Stop using bitfields in register
 definition structures
Date: Tue, 1 Oct 2013 16:37:14 +0100
Message-ID: <1380641834.1939.3.camel@bwh-desktop.uk.level5networks.com>
References: <1379960098.2485.48.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	David Laight <David.Laight@ACULAB.COM>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62706 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab3JAPhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 11:37:17 -0400
In-Reply-To: <1379960098.2485.48.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 19:14 +0100, Ben Hutchings wrote:
> This doesn't make any difference to the static data size, and
> decreases the code size a little.
> 
> Reported-by: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  sfc.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)

I've now applied this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
