From: Martin Langer <martin-langer@gmx.de>
Subject: Re: [PATCH] bcm43xx-softmac: improve wrong firmware message
Date: Tue, 12 Sep 2006 23:49:39 +0200
Message-ID: <20060912214939.GA3750@tuba>
References: <45071890.mailJEJ1PQOHG@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Michael Buesch <mb@bu3sch.de>,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:30112 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751466AbWILVts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 17:49:48 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <45071890.mailJEJ1PQOHG@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2006 at 03:29:04PM -0500, Larry Finger wrote:
> An error message is changed to a printk as the original dprintk would
> be optimized away if debugging were not enabled. If the error is triggered,
> a more meaningful message is returned.
> 
>  
>  	if ( value16 > 0x128 ) {
> -		dprintk(KERN_ERR PFX
> -			"Firmware: no support for microcode rev > 0x128\n");
> -		err = -1;
> +		printk(KERN_ERR PFX
> +			"Firmware: no support for microcode extracted "
> +			"from version 4.x binary drivers.\n");

Why not writing both (ucode rev and driver version)? Something like 

	"from version 4.x binary drivers (rev>0x128).\n"

BTW, if anybody needs the relationship between ucode revsion and driver 
version then he should look at the table here:

http://www.langerland.de/linux/bcm43xx/firmware.html


Martin
