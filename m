From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Thu, 25 Oct 2012 15:17:48 -0500
Message-ID: <50899E6C.8040403@freescale.com>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com> <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net> <50883D03.1000600@windriver.com> <50883DB7.4030502@freescale.com> <20121025200853.GA6151@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yang <Wei.Yang@windriver.com>,
	Manoil Claudiu-B08782 <B08782@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:38383
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934218Ab2JYURy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 16:17:54 -0400
In-Reply-To: <20121025200853.GA6151@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:

> Getting back to your really ignorant comment, I suggest that you look
> at this review. It was made by Grant Likely. Perhaps you have heard of
> him?
> 
>   https://lkml.org/lkml/2011/2/23/281
> 
> I was the original developer of the PTP code, and my code went through
> fifteen rounds of review. And guess what - I actually listened to the
> reviewer's comments and changed my work accordingly.

I'm sorry for what I said.  It was inappropriate.  I deal with crappy code
from co-workers on a daily basis, and sometimes I forgot that just because
something is done differently than I would have done it, that doesn't mean
it's wrong.

> You can read all about what happened, but you will have to find v15
> yourself. Be sure to pay special attention to the history of
> irq_of_parse_and_map() verses platform_get_irq().

I actually did that research and saw Grant's comments.  I asked him about
it on IRC, and although I understand his reasoning, I'm not sure I agree
with all of it.  In particular, I think
platform_get_resource/request_resource/ioremap is less elegant than just
calling of_iomap.


-- 
Timur Tabi
Linux kernel developer at Freescale
