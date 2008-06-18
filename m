From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sfc: I2C adapter initialisation fixes
Date: Tue, 17 Jun 2008 23:48:55 -0400
Message-ID: <485885A7.5060409@pobox.com>
References: <cover.1213035602.git.bhutchings@solarflare.com> <20080609182509.GJ11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jean Delvare <khali@linux-fr.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40601 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757518AbYFRDtA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:49:00 -0400
In-Reply-To: <20080609182509.GJ11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> As recommended by Jean Delvare:
> - Increase timeout to 50 ms
> - Leave adapter class clear so that unwanted drivers do not probe our bus
> - Use strlcpy() for name initialisation
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/falcon.c |   12 +++---------
>  1 files changed, 3 insertions(+), 9 deletions(-)

I didn't see a resend of this with Jean's requested change?


