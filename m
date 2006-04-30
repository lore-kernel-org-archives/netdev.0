From: Nuri Jawad <lkml@jawad.org>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16 - updates
Date: Sun, 30 Apr 2006 06:31:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0604300558001.2331@pc>
References: <20060421010809.6c3cfc34.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from leitseite.net ([213.239.214.51]:20956 "EHLO mail.leitseite.net")
	by vger.kernel.org with ESMTP id S1750915AbWD3Ebg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2006 00:31:36 -0400
Received: from pc ([10.1.0.2] helo=nj.yi.org)
	by mail.leitseite.net with esmtp (Exim 4.34)
	id 1Fa3ag-0001Hj-NV
	for netdev@vger.kernel.org; Sun, 30 Apr 2006 06:31:26 +0200
Received: from localhost (localhost [127.0.0.1])
	by nj.yi.org (Postfix) with ESMTP id 715781D889C
	for <netdev@vger.kernel.org>; Sun, 30 Apr 2006 06:31:14 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060421010809.6c3cfc34.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more info:

- turning off Hyper Threading and using a uniprocessor kernel
   did not improve things
- so didn't using 2.6.17rc3, in fact the bug manifested after
   only 4 minutes with a 43 seconds gap
- those kernel debug watchdog routines don't detect anything

Going to try kernel PPPoE next time. Btw, at least with rp-pppoe 
it requires HDLC and that dependency isn't caught in menuconfig.

I would try to roll back some patches between 2.6.15.7 and 2.6.16 but
that changelog is pretty large. I'm sure there are good reasons for 
the current development model, but with the old unstable/stable
system and its few changes between stable versions, the right
one could've been spotted easily :/.

Regards, Nuri
