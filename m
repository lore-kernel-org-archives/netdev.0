From: bora.sahin@ttnet.net.tr
Subject: Re: [PATCH 12/12] smc911x: afc_cfg calculation is wrong at case 5
Date: Thu, 14 Sep 2006 12:21:16 +0300
Message-ID: <200609141221.16279.bora.sahin@ttnet.net.tr>
References: <200609132137.47905.bora.sahin@ttnet.net.tr> <20060913190234.GG25007@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="Iso-8859-9"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:34084 "EHLO
	fep04.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751486AbWINJRB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 05:17:01 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060913190234.GG25007@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 September 2006 22:02, Francois Romieu wrote:
> bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
> [...]
> > BACKDUR  calculation is wrong at case 5. Also some cosmetic around
> > smc911x_probe...
> 
> If you are in a mood for cosmetic, feel free to turn some unsigned
> long ioaddr into something more void __iomem *ioaddr and store it
> in the private part of the device struct instead of dev->base_addr.

like 
	struct smc911x_local *lp = netdev_priv(dev);
	void __iomem *ioaddr = lp->base_addr;
?
 
> [...]
> > @@ -1977,7 +1975,7 @@
> >  		case 4:/* 11520 Rx Data Fifo Size */
> >  			lp->afc_cfg=0x00783C9F;break;
> >  		case 5:/* 10560 Rx Data Fifo Size */
> > -			lp->afc_cfg=0x006E374F;break;
> > +			lp->afc_cfg=0x006E378F;break;
> 
> Not your fault but the break statement is misplaced.

One line below? 

Thanks for all of your comments. I will create a new set of patches...

--
Bora SAHIN
