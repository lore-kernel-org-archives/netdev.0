From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: Silicom bypass driver promote from staging
Date: Thu, 7 Aug 2014 13:19:47 -0700
Message-ID: <20140807201947.GA6060@kroah.com>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
 <20140805150957.GC27303@kroah.com>
 <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:47820 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaHGUTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 16:19:48 -0400
Content-Disposition: inline
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2014 at 09:26:54AM +0000, David Hendel wrote:
> Hello Netdev group,
> 
> For the /driver/staging/silicom that we want to promote.
> We have our bypass driver updated and we would like to move forward with integrating it into the kernel mainline We are not sure of what is the best location to have these driver located, as this is not really a network driver.
> The options that we see are:
> driver/misc/silicom/...
> driver/char/silicom/...
> driver/bypass/silicom/....
> 
> The description of the functionality of the driver is below per readme of this driver in the /driver/staging/silicom.
> 
> Currently in the attached driver we have defined it to be in driver/bypass/silicom/....
> If this is OK with you then we can continue with that. if you thing that it needs to be in another location then we can change the patch.

Making your patch an attachment in base64 mode, makes it impossible to
quote to review it :(

Anyway, I stopped at the first header file.  The kernel already has BIT
definitions, no driver should ever have to redefine these and do it on
their own.  That leads me to believe that this code really isn't all
that "cleaned up" at all.

Should I just look at what is in drivers/staging/silicom/ right now as
code to review?  Or have you changed it any by making this patch?

thanks,

greg k-h
