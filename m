From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: Is the qla3xxx driver in the mainline?
Date: Thu, 27 Jul 2006 05:35:31 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC072C5FDE@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Doug Maxey" <dwm@enoyolf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:4373 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1751183AbWG0Mff convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 08:35:35 -0400
Content-class: urn:content-classes:message
To: <albertl@mail.com>, "Michael Tokarev" <mjt@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Qla3xxx only supports QLA4022 at this time.  It will soon be patched to
support QLA4032.  There is no plan to add QLA4010 support. 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Albert Lee
> Sent: Wednesday, July 26, 2006 8:16 PM
> To: Michael Tokarev
> Cc: netdev@vger.kernel.org; Doug Maxey
> Subject: Re: Is the qla3xxx driver in the mainline?
> 
> Michael Tokarev wrote:
> > Albert Lee wrote:
> > []
> > 
> >>(I am curious to have some performance comparison of qla3xxx + open 
> >>iscsi v.s. qla4xxx + on board TOE/iscsi.)
> > 
> > 
> > On wich card?  I've been told that IPS4010 for example 
> isn't supported 
> > by qla3xxx.
> 
> I've borrowed an ISP4022 based adapter, the qla3xxx should be 
> supported.
> 
> > 
> > BTW, I found qla4xxx (on IPS4010) performs noticeable worse than 
> > open-iscsi stack on top of tigon (non-jumbo-
> > frames-capable) GigE NIC (on an eserver xSeries 346 machine).
> > 
> 
> Thanks for the info. With qla3xxx, we can actually use
> the Ethernet interface of the qla4022 instead of the bcm57xx
> tg3. So, we could compare the performance of the on-board
> TOE/iscsi with open-iscsi better.
> 
> --
> albert
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
