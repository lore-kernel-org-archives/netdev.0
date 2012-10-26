From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Fri, 26 Oct 2012 12:32:44 +0200
Message-ID: <20121026103243.GA3092@netboy.at.omicron.at>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com>
 <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net>
 <50883D03.1000600@windriver.com>
 <50883DB7.4030502@freescale.com>
 <20121025200853.GA6151@netboy.at.omicron.at>
 <50899E6C.8040403@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yang <Wei.Yang@windriver.com>,
	Manoil Claudiu-B08782 <B08782@freescale.com>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:48611 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755501Ab2JZKcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 06:32:53 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so783516eaa.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 03:32:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <50899E6C.8040403@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 03:17:48PM -0500, Timur Tabi wrote:
> 
> I'm sorry for what I said.  It was inappropriate.  I deal with crappy code
> from co-workers on a daily basis, and sometimes I forgot that just because
> something is done differently than I would have done it, that doesn't mean
> it's wrong.

Thanks for that apology. Now my wounded pride has recovered :)

> I actually did that research and saw Grant's comments.  I asked him about
> it on IRC, and although I understand his reasoning, I'm not sure I agree
> with all of it.  In particular, I think
> platform_get_resource/request_resource/ioremap is less elegant than just
> calling of_iomap.

No comment from me, since I always seem to lose at the DT game.

Thanks,
Richard
