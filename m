From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/3] Fix phy id for LXT971A/LXT972A
Date: Sun, 25 Jun 2006 05:15:29 -0400
Message-ID: <449E5431.3020904@garzik.org>
References: <200606250844.k5P8ichl020797@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Uwe_Zeisberger@digi.com,
	afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12265 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932142AbWFYJPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 05:15:33 -0400
To: akpm@osdl.org
In-Reply-To: <200606250844.k5P8ichl020797@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Uwe Zeisberger <Uwe_Zeisberger@digi.com>
> 
> The phy ids used are taken from an driver that used a right shift of 4 to chop
> off the revision number.  This driver does not shift, so the id and mask
> values are wrong and must be left shifted by 4 to actually detect the chips.
> 
> Signed-off-by: Uwe Zeisberger <Uwe_Zeisberger@digi.com>
> Acked-by: Andy Fleming <afleming@freescale.com>
> 
> [akpm: this is a previously-nacked patch, but the problem is real]
> Signed-off-by: Andrew Morton <akpm@osdl.org>

This was nak'd?  Does anyone recall why?

	Jeff



