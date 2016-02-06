From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH net v4] r8169: Add bios support.
Date: Sat, 06 Feb 2016 15:57:34 +0200
Message-ID: <1454767054.4383.2.camel@marian1000.go.ro>
References: <1454740286-4738-1-git-send-email-asd@marian1000.go.ro>
	 <20160206.023932.2140900219779859048.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-192.residential.rdsnet.ro ([5.14.227.192]:45872 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbcBFOSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 09:18:49 -0500
In-Reply-To: <20160206.023932.2140900219779859048.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-02-06 at 02:39 -0500, David Miller wrote:
> From: Corcodel Marian <asd@marian1000.go.ro>
> Date: Sat,  6 Feb 2016 08:31:26 +0200
> 
> > @@ -8262,8 +8262,9 @@ static int rtl_init_one(struct pci_dev *pdev,
> const struct pci_device_id *ent)
> >       rtl_hw_reset(tp);
> >  
> >       rtl_ack_events(tp, 0xffff);
> > -
> > +#ifndef CONFIG_BIOS_SUPPORT
> >       pci_set_master(pdev);
> > +#endif
> 
> I already made it clear to you that it is perfectly fine to
> unconditionally
> call pci_set_master() from the driver in any circumstance.
> 
> Look across all of the drivers under drivers/net/ that invoke this
> function,
> it's meant to be used this way and it's fine.
> 
> There is absolutely no reason to conditionalize it.
> 
> Thanks.
> 

May be but i'm not sure this must tested on every driver.
