From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/3] net/mlx4_en: Add HW timestamping (TS) support
Date: Thu, 4 Oct 2012 16:27:35 +0200
Message-ID: <20121004142734.GA2810@netboy.at.omicron.at>
References: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
 <1348826603-17439-4-git-send-email-yevgenyp@mellanox.com>
 <20120928111147.GA7474@netboy.at.omicron.at>
 <74A0102445410646AFACC089FD94803A95ED92DD@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Eugenia Emantayev <eugenia@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57625 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964963Ab2JDO1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 10:27:46 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so4377446wib.1
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 07:27:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <74A0102445410646AFACC089FD94803A95ED92DD@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 04, 2012 at 02:08:29PM +0000, Eugenia Emantayev wrote:
> > Also, why not expose your device as a PTP Hardware Clock?
> 
> Hello Richard,
> Could you please clarify the above?
> What do you mean by expose your device as a PTP Hardware Clock?

You could register the driver as PHC class device, described in

   Documentation/ptp/ptp.txt

and then you device will work together along with a user space PTP
stack, like the one I wrote at

   http://linuxptp.sourceforge.net

Thanks,
Richard
