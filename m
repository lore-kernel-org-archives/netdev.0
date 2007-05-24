From: jamal <hadi@cyberus.ca>
Subject: Re: [RESEND][PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Thu, 24 May 2007 09:38:33 -0400
Message-ID: <1180013913.4092.7.camel@localhost>
References: <1179972902.4082.63.camel@localhost>
	 <46550965.5000400@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Peter P <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Auke <auke-jan.h.kok@intel.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, xma@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:47592 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695AbXEXNih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 09:38:37 -0400
Received: by wx-out-0506.google.com with SMTP id t15so351568wxc
        for <netdev@vger.kernel.org>; Thu, 24 May 2007 06:38:36 -0700 (PDT)
In-Reply-To: <46550965.5000400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-24-05 at 05:41 +0200, Patrick McHardy wrote:
> jamal wrote:
> > +	if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
> > +		printk(KERN_DEBUG " BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);
> 
> 
> This seems to be based on an old version, your latest patch
> changed this to KERN_WARNING.

sigh. 
I wont be able to do this change until tonight or tommorow morning. I
think the process i am using to re-generate patches maybe too consuming?
Maybe you could offer some advice. Heres what i do:
1. clone Daves latest tree localy
2. clone another tree from that
3. create patch on second clone
4. compile; test;compile;test until looks reasonable
5. commit with the comments
6. submit
7. build other patches on top (example batching in this case)
8. feedback on patch comes back
9. Re-do steps #2-#6

My steps #2-#6 are expensive; is there a way to optimize that process?
 
cheers,
jamal

