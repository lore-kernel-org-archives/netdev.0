From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 05/07: reintroduce dev->qdisc for use by sch_api
Date: Mon, 07 Sep 2009 15:16:29 +0200
Message-ID: <4AA507AD.6000403@trash.net>
References: <20090906185757.GA8833@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33835 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZIGNQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 09:16:30 -0400
In-Reply-To: <20090906185757.GA8833@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
>> @@ -1383,7 +1375,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
>>  			pid = TC_H_MAKE(qid, pid);
>>  	} else {
>>  		if (qid == 0)
>> -			qid = dev_queue->qdisc_sleeping->handle;
>> +			qid = dev->qdisc->handle;
> 
> Probably I miss something, but in mq root case it seems to never do
> anything we need. If so, it could be the example of possible issues
> elsewhere.

Sorry, I'm not sure what you're saying ..

> I thought this mq virtual root qdisc could be done more transparently
> and invisible for the current code, but it seems, in your
> implementation some pointers like this, or parent ids (especially
> TC_H_ROOT) might be different, and even if it works OK, needs a lot of
> verification. So, my question is, if it's really necessary.

Same here.
