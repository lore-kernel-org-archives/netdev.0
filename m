From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next 4/8] qlcnic: Add support for PEX DMA method to
 read memory section of adapter dump
Date: Thu, 27 Jun 2013 14:29:14 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4DB24F@avmb2.qlogic.org>
References: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com>
 <1371832261-18930-5-git-send-email-jitendra.kalsaria@qlogic.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B72A0@saturn3.aculab.com>
 <262CB373A6D1F14F9B81E82F74F77D5A4DAE09@avmb2.qlogic.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B72AC@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0250.outbound.messaging.microsoft.com ([213.199.154.250]:59330
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751663Ab3F0O3X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 10:29:23 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B72AC@saturn3.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Thursday, June 27, 2013 1:56 AM
> To: Shahed Shaikh; Jitendra Kalsaria; David Miller
> Cc: netdev; Sony Chacko; Dept-NX Linux NIC Driver
> Subject: RE: [PATCH net-next 4/8] qlcnic: Add support for PEX DMA method
> to read memory section of adapter dump
> 
> > > > +	if ((tmpl_hdr->version & 0xffffff) >= 0x20001)
> > > > +		ahw->fw_dump.use_pex_dma = true;
> > > > +	else
> > > > +		ahw->fw_dump.use_pex_dma = false;
> > >
> > > You know what's wrong with the above....
> >
> > Yes. Got it.  Masking is not done properly. It should be if
> > ((tmpl_hdr->version & 0xfffff) >= 0x20001)
> 
> Try:
> 	ahw->fw_dump.use_pex_dma = (tmpl_hdr->version & 0xfffff) >=
> 0x20001;
> 
Ok. Thanks David.

-Shahed

> 	David
> 
> 
> 
