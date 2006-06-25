From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/3] Fix phy id for LXT971A/LXT972A
Date: Sun, 25 Jun 2006 02:44:23 -0700
Message-ID: <20060625024423.1bc26186.akpm@osdl.org>
References: <200606250844.k5P8ichl020797@shell0.pdx.osdl.net>
	<449E5431.3020904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Uwe_Zeisberger@digi.com,
	afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21916 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932187AbWFYJob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 05:44:31 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <449E5431.3020904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 25 Jun 2006 05:15:29 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> akpm@osdl.org wrote:
> > From: Uwe Zeisberger <Uwe_Zeisberger@digi.com>
> > 
> > The phy ids used are taken from an driver that used a right shift of 4 to chop
> > off the revision number.  This driver does not shift, so the id and mask
> > values are wrong and must be left shifted by 4 to actually detect the chips.
> > 
> > Signed-off-by: Uwe Zeisberger <Uwe_Zeisberger@digi.com>
> > Acked-by: Andy Fleming <afleming@freescale.com>
> > 
> > [akpm: this is a previously-nacked patch, but the problem is real]
> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> 
> This was nak'd?  Does anyone recall why?
> 

No, it was not nacked - I'd simply misfiled it (actually, failed to refile
it after we got a changelog).

