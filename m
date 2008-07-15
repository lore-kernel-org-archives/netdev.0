From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: Only route multicast trafic in init_net
Date: Mon, 14 Jul 2008 22:59:52 -0700
Message-ID: <m1bq0zhelj.fsf@frodo.ebiederm.org>
References: <m1od54dwar.fsf@frodo.ebiederm.org>
	<20080714.222553.228256571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40867 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbYGOGCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 02:02:13 -0400
In-Reply-To: <20080714.222553.228256571.davem@davemloft.net> (David Miller's
	message of "Mon, 14 Jul 2008 22:25:53 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 11 Jul 2008 13:02:04 -0700
>
>> 
>> Currently the code to only support multicast traffic in the initial
>> namespace is incomplete, and receiving a multicast packet causes in a
>> network namespace causes us to take an initialized lock.  Resulting
>> in a nasty oops. Ouch!
>> 
>> So until we have network namespace support in igmp.c simply disable
>> multicast packet reception.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> Grumble...
>
> So you send me a patch later which depended upon these ones and yet
> you made no mention of this dependency.

Sorry I thought I had.  I mentioned the other patch applied on top of
my previous patch.  I guess I did not say it clearly enough.  
With [PATCH 1/2] [PATCH 2/2].  

> Can you just resend me whatever I should add right now?
Sure. 

Eric

