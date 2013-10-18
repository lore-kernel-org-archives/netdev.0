From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Thu, 17 Oct 2013 21:20:45 -0400
Message-ID: <1970192.CQWcaac4RA@sifl>
References: <2291823.ee0I8c00DA@olly> <3511324.zOrNRFllMJ@sifl> <20131017.154742.370913034142395176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, dima@marvell.com
To: seif@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:33561 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab3JRBUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 21:20:49 -0400
Received: by mail-qe0-f44.google.com with SMTP id 6so1280261qeb.3
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 18:20:49 -0700 (PDT)
In-Reply-To: <20131017.154742.370913034142395176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, October 17, 2013 03:47:42 PM David Miller wrote:
> From: Paul Moore <paul@paul-moore.com>
> Date: Mon, 14 Oct 2013 11:12:47 -0400
> 
> > On Saturday, October 12, 2013 10:21:50 PM Seif Mazareeb wrote:
> >> When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could
> >> loop forever in the main loop if opt[opt_iter +1] == 0, this will causing
> >> a
> >> kernel crash in an SMP system, since the CPU executing this function will
> >> stall /not respond to IPIs.
> >> 
> >> This problem can be reproduced by running the IP Stack Integrity Checker
> >> (http://isic.sourceforge.net) using the following command on a Linux
> >> machine connected to DUT:
> >> 
> >> "icmpsic -s rand -d <DUT IP address> -r 123456"
> >> wait (1-2 min)
> >> 
> >> Signed-off-by: Seif Mazareeb <seif@marvell.com>
> > 
> > Thanks for sticking with this.
> > 
> > Acked-by: Paul Moore <paul@paul-moore.com>
> 
> This patch, like all the others Seif submitted, has been corrupted by
> his email client and is this unusable.

Seif, please fix this.  If I don't see a new patch by tomorrow I'll go ahead 
and resubmit.

-- 
paul moore
www.paul-moore.com
