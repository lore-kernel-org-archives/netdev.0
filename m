From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/11][TG3]: Add TG3_FLAG_SUPPORT_MSI flag.
Date: Sat, 05 May 2007 13:09:47 -0700 (PDT)
Message-ID: <20070505.130947.124083244.davem@davemloft.net>
References: <1178326494.4859.24.camel@dell>
	<463BD213.2070004@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55806
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933264AbXEEUKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 16:10:00 -0400
In-Reply-To: <463BD213.2070004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 04 May 2007 20:38:43 -0400

> Michael Chan wrote:
> > @@ -10404,6 +10400,8 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
> >  	}
> >  }
> >  
> > +static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
> > +
> >  static int __devinit tg3_get_invariants(struct tg3 *tp)
> >  {
> >  	static struct pci_device_id write_reorder_chipsets[] = {
> 
> 
> Prototypes are better kept at the top of the file, grouped together.  It 
> can sometimes be a pain later on, if they are scattered throughout a big 
> source file like tg3.c.
> 
> ACK the patch's content of course

I disagree with this.  In my drivers I try to keep the forward
declarations as far down in the file as possible, so that functions
are only visible to the stuff that actually needs it.

In any event, even if I agreed with this idea, the tg3.c driver
has not followed that convention and such a switch over
would be a seperate change.

Patch applied, thanks Michael.

