From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 09:11:01 +0900
Message-ID: <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
 <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com>
 <5230B435.2050908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:30263 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab3ILALI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 20:11:08 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSZ00GO0KI4U390@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 12 Sep 2013 09:11:02 +0900 (KST)
In-reply-to: <5230B435.2050908@cogentembedded.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 12, 2013 3:20 AM, Jingoo Han wrote:
> On 09/11/2013 11:40 AM, Jingoo Han wrote:
> 
> > The driver core clears the driver data to NULL after device_release
> > or on probe failure. Thus, it is not needed to manually clear the
> > device driver data to NULL.
> 
> > Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> > ---
> >   drivers/net/ethernet/fealnx.c |    4 ++--
> >   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
> > index c706b7a..99194d1 100644
> > --- a/drivers/net/ethernet/fealnx.c
> > +++ b/drivers/net/ethernet/fealnx.c
> > @@ -699,9 +699,9 @@ static void fealnx_remove_one(struct pci_dev *pdev)
> >   		pci_iounmap(pdev, np->mem);
> >   		free_netdev(dev);
> >   		pci_release_regions(pdev);
> > -		pci_set_drvdata(pdev, NULL);
> > -	} else
> > +	} else {
> >   		printk(KERN_ERR "fealnx: remove for unknown device\n");
> > +	}
> 
>     No "drove-by" coding style fixes, please.

Hi Sergei,

Sorry, but I just want to know the reason. :-)
Would you let know the reason not to add coding style fixes?
Thank you.

Best regards,
Jingoo Han
