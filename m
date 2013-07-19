From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [RFC] qlcnic: Enhance ethtool to display board temperature.
Date: Fri, 19 Jul 2013 18:00:10 +0000
Message-ID: <ADFE82A996F10145934E45547759F763311A265D@avmb3.qlogic.org>
References: <1374206237-27233-1-git-send-email-himanshu.madhani@qlogic.com>
 <20130719091128.068e5514@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:10750 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752847Ab3GSSAP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jul 2013 14:00:15 -0400
In-Reply-To: <20130719091128.068e5514@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Friday, July 19, 2013 9:11 AM
> To: Himanshu Madhani
> Cc: netdev; David Miller; Dept-NX Linux NIC Driver
> Subject: Re: [RFC] qlcnic: Enhance ethtool to display board temperature.
> 
> 
> >  static int
> > diff --git a/include/uapi/linux/ethtool.h
> > b/include/uapi/linux/ethtool.h index 38dbafa..2012015 100644
> > --- a/include/uapi/linux/ethtool.h
> > +++ b/include/uapi/linux/ethtool.h
> > @@ -101,6 +101,7 @@ struct ethtool_drvinfo {
> >  	__u32	testinfo_len;
> >  	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM
> (bytes) */
> >  	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes)
> */
> > +	__u32	board_temp;     /* board temperature */
> >  };
> 
> The idea is good but a couple of comments.
> 1. you can't break userspace ABI for ethtool by adding elements.
> 
> 2. There already exists a hardware monitoring subsystem in
>    Linux and there are applications that use it (like SNMP. If you want this
> feature to
>    be more than a developer toy, then it should use the existing subsystem
> API's.

Thanks for the comment. I will use ethtool -S ethX option to display board
Temperature. 
