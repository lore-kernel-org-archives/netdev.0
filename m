From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Wed, 09 May 2007 01:12:01 -0700 (PDT)
Message-ID: <20070509.011201.68040843.davem@davemloft.net>
References: <20070508.233630.35664266.davem@davemloft.net>
	<OF6A57F86D.C63329E8-ON652572D6.0027B2E9-652572D6.00289106@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbXEIIMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 04:12:00 -0400
In-Reply-To: <OF6A57F86D.C63329E8-ON652572D6.0027B2E9-652572D6.00289106@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 9 May 2007 12:53:05 +0530

> David Miller <davem@davemloft.net> wrote on 05/09/2007 12:06:30 PM:
> 
> > Your change will make the kernel essentially hang instead
> > when this bug check is triggered.
> 
> By returning -1, we end up freeing all the skbs one by one, or
> until the condition : "transient error caused by hard_start_xmit
> recursing" is over. Essentially, that behavior is also not
> changed in my patch (only run time change is to return 0 if
> there are no more skbs).

Something this evening is obviously making it impossible
for my brain to understand this function and your patch,
so I'm going to sleep on it and try again tomorrow :-)
