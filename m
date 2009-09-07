From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 05/07: reintroduce dev->qdisc for use by sch_api
Date: Mon, 7 Sep 2009 18:49:29 +0200
Message-ID: <20090907164929.GA4451@ami.dom.local>
References: <20090906185757.GA8833@ami.dom.local>
 <4AA507AD.6000403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44205 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbZIGQtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 12:49:46 -0400
Received: by bwz19 with SMTP id 19so1688650bwz.37
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 09:49:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AA507AD.6000403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 07, 2009 at 03:16:29PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> >> @@ -1383,7 +1375,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
> >>  			pid = TC_H_MAKE(qid, pid);
> >>  	} else {
> >>  		if (qid == 0)
> >> -			qid = dev_queue->qdisc_sleeping->handle;
> >> +			qid = dev->qdisc->handle;
> > 
> > Probably I miss something, but in mq root case it seems to never do
> > anything we need. If so, it could be the example of possible issues
> > elsewhere.
> 
> Sorry, I'm not sure what you're saying ..
> 
> > I thought this mq virtual root qdisc could be done more transparently
> > and invisible for the current code, but it seems, in your
> > implementation some pointers like this, or parent ids (especially
> > TC_H_ROOT) might be different, and even if it works OK, needs a lot of
> > verification. So, my question is, if it's really necessary.
> 
> Same here.

Nevermind! I simply had a dream there could be preserved some old
meaning of "root" etc. within a queue but it doesn't make a sense with
this kind of interface.

Jarek P.
