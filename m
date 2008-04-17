From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26 1/2] phylib: factor out get_phy_id from within
 get_phy_device
Date: Wed, 16 Apr 2008 20:55:01 -0400
Message-ID: <48069FE5.6020008@pobox.com>
References: <1208278162-17462-1-git-send-email-paul.gortmaker@windriver.com> <1208278162-17462-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57544 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753049AbYDQAzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 20:55:02 -0400
In-Reply-To: <1208278162-17462-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker wrote:
> We were already doing what amounts to a get_phy_id from within
> get_phy_device, and rather than duplicate this for the TBIPA
> probing, we might as well just factor it out and make it available
> instead.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Acked-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/phy/phy_device.c |   38 +++++++++++++++++++++++++++++---------
>  include/linux/phy.h          |    1 +
>  2 files changed, 30 insertions(+), 9 deletions(-)

applied.

a well-split-up patch series, good show :)

