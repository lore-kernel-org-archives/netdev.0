From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] tg3: Prevent system hang during repeated
 EEH errors.
Date: Mon, 17 Jun 2013 12:11:06 -0700
Message-ID: <1371496266.5012.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1371244506-18969-1-git-send-email-nsujir@broadcom.com>
 <20130617182811.GA12442@d2.synalogic.ca>
 <20130617185647.GB12442@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Nithin Nayak Sujir" <nsujir@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Benjamin Poirier" <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1362 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab3FQTLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 15:11:22 -0400
In-Reply-To: <20130617185647.GB12442@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-17 at 14:56 -0400, Benjamin Poirier wrote:
> Nevertheless, this hunk
> 
> > > @@ -17826,6 +17833,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
> > >     if (err) {
> > >             tg3_full_unlock(tp);
> > >             netdev_err(netdev, "Cannot restart hardware after reset.\n");
> > > +           tg3_napi_enable(tp);
> > > +           dev_close(netdev);
> > >             goto done;
> > >     }
> 
> duplicates the error handling code already in tg3_restart_hw(). 

Very good point.  We'll modify the patch and re-send.  Thanks a lot
Benjamin.
