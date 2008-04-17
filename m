From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26 2/2] gianfar: Determine TBIPA value dynamically
Date: Wed, 16 Apr 2008 20:55:51 -0400
Message-ID: <4806A017.4000107@pobox.com>
References: <1208278162-17462-1-git-send-email-paul.gortmaker@windriver.com> <1208278162-17462-2-git-send-email-paul.gortmaker@windriver.com> <1208278162-17462-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57557 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752452AbYDQAzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 20:55:53 -0400
In-Reply-To: <1208278162-17462-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker wrote:
> TBIPA needs to be set to a value (on connected MDIO buses) that doesn't
> conflict with PHYs on the bus.  By hardcoding it to 0x1f, we were preventing
> boards with PHYs at 0x1f from working properly.  Instead, scan the bus when
> it comes up, and find an address that doesn't have a PHY on it.  The TBI PHY
> configuration code then trusts that the value in TBIPA is either safe, or
> doesn't matter (ie - it's not an active bus with other PHYs).
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  drivers/net/gianfar.c     |   27 ++++++++++++++-------------
>  drivers/net/gianfar.h     |    1 -
>  drivers/net/gianfar_mii.c |   38 +++++++++++++++++++++++++++++++++-----
>  drivers/net/gianfar_mii.h |    3 +++
>  4 files changed, 50 insertions(+), 19 deletions(-)

ACK, but failed to apply

please rediff against jgarzik/netdev-2.6.git#upstream or its parent, 
davem/net-2.6.26.git


