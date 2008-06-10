From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sfc: Recover from RX queue flush failure
Date: Tue, 10 Jun 2008 18:22:03 -0400
Message-ID: <484EFE8B.2020301@pobox.com>
References: <cover.1213035645.git.bhutchings@solarflare.com> <20080609183431.GL11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38990 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757647AbYFJWWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:22:04 -0400
In-Reply-To: <20080609183431.GL11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> From: Steve Hodgson <shodgson@solarflare.com>
> 
> RX queue flush can fail if traffic continues to arrive.  Recover by
> performing an invisible reset.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/falcon.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)

applied


