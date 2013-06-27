From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v1 2/3] pch_gbe: convert pr_* to netdev_*
Date: Thu, 27 Jun 2013 10:55:06 +0300
Message-ID: <1372319706.24799.72.camel@smile>
References: <1372263217-1938-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1372263217-1938-3-git-send-email-andriy.shevchenko@linux.intel.com>
	 <20130626.134108.1845027788447841042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, dvhart@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35121 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241Ab3F0HzN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 03:55:13 -0400
In-Reply-To: <20130626.134108.1845027788447841042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 13:41 -0700, David Miller wrote: 
> From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Date: Wed, 26 Jun 2013 19:13:36 +0300
> 
> > diff --git a/drivers/staging/media/lirc/lirc_igorplugusb.c b/drivers/staging/media/lirc/lirc_igorplugusb.c
> > index 28c8b0b..25df7cf 100644
> > --- a/drivers/staging/media/lirc/lirc_igorplugusb.c
> > +++ b/drivers/staging/media/lirc/lirc_igorplugusb.c
> > @@ -408,7 +408,7 @@ static int igorplugusb_remote_probe(struct usb_interface *intf,
> >  	dprintk(DRIVER_NAME "[%d]: bytes_in_key=%zu maxp=%d\n",
> >  		devnum, CODE_LENGTH, maxp);
> >  
> > -	ir = devm_kzalloc(&intf->dev, sizeof(*ir), GFP_KERNEL);
> > +	ir = devm_kzalloc(&dev->dev, sizeof(*ir), GFP_KERNEL);
> >  	if (!ir)
> >  		return -ENOMEM;
> >  
> 
> This definitely wasn't supposed to be in this patch series.
> 
> Please repost this set with this hunk removed.

Oops, sure.

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
