From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sfc: Correct address of gPXE boot configuration in EEPROM
Date: Thu, 06 Nov 2008 00:42:48 -0500
Message-ID: <491283D8.70207@pobox.com>
References: <20081103230803.GU7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34693 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbYKFFmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 00:42:51 -0500
In-Reply-To: <20081103230803.GU7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Due to a hardware bug, the originally assigned range cannot reliably
> be used for boot configuration and must not be modifiable through
> ethtool.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This is for 2.6.28.  It only affects the ethtool EEPROM access code
> that is new in this release cycle.
> 
> Ben.
> 
>  drivers/net/sfc/ethtool.c |    4 ++--

applied


