From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/3] net/mlx4_en: Add HW timestamping (TS) support
Date: Fri, 5 Oct 2012 12:38:19 +0200
Message-ID: <20121005103819.GA2555@netboy.at.omicron.at>
References: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
 <1348826603-17439-4-git-send-email-yevgenyp@mellanox.com>
 <20120928111147.GA7474@netboy.at.omicron.at>
 <74A0102445410646AFACC089FD94803A95ED92DD@MTLDAG01.mtl.com>
 <20121004142734.GA2810@netboy.at.omicron.at>
 <74A0102445410646AFACC089FD94803A95ED9341@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Eugenia Emantayev <eugenia@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37799 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab2JEKiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 06:38:24 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so953016wey.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 03:38:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <74A0102445410646AFACC089FD94803A95ED9341@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 04, 2012 at 08:58:59PM +0000, Eugenia Emantayev wrote:
> > You could register the driver as PHC class device, described in
> >
> >   Documentation/ptp/ptp.txt
> >
> > and then you device will work together along with a user space PTP stack, like the one I wrote at
> >
> >   http://linuxptp.sourceforge.net
> 
> 
> Richard,
> 
> Thanks for the explanation.
> At this stage we prefer to submit the initial patch set (V1) and then, at the next phase,
> extend it as you suggested above, after learning and better understanding the requirements
> and effects.

Well, if you want to provide a way to relate your hardware time stamps
with the system time, then you need to implement the PHC.  Please do
not make use of the timecompare code in your driver, since it is going
to be removed soon.

Thanks,
Richard
