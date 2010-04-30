From: Tejun Heo <tj@kernel.org>
Subject: Re: patch sysfs-implement-sysfs-tagged-directory-support.patch added
 to gregkh-2.6 tree
Date: Fri, 30 Apr 2010 07:37:20 +0200
Message-ID: <4BDA6C90.9010303@kernel.org>
References: <12725729473590@kroah.org> <4BDA5A2D.6080904@kernel.org>	<20100430044522.GA29845@suse.de> <m1aaslbjh4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, bcrl@lhnet.ca, benjamin.thery@bull.net,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com,
	kay.sievers@vrfy.org, netdev@vger.kernel.org, serue@us.ibm.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:60359 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757259Ab0D3RE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:04:28 -0400
In-Reply-To: <m1aaslbjh4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 04/30/2010 07:24 AM, Eric W. Biederman wrote:
>>> I wish at least more comments are added before it goes mainline.  I
>>> don't really understand the current form.
>>
>> Ok, that's fine with me, I'll pull it back out.
> 
> ?????
> 
> Tejun you have offered nothing constructive to the review, except looking
> and saying you don't understand what is going on.

Eric, no need to get too touchy and you're right in part in saying all
I'm saying is basically "I don't understand it" which is the same
reason why I'm not nacking it and explicitly stated that I would be
okay with the series going in if Greg/Kay would be okay with it.
Again, about the same thing with the above comment, I was *wishing*
for more comments *before it goes mainline*.

> Tejun I think for the code to make any sense to you I would need to rip
> out out and/or rewrite the kobject layer, and possible the device
> model code as well.

And yes, in the long run, please do that.

> Tejun I'm sorry you can't understand the code, and I'm sorry the code
> may be over-general.  In part that is because making the code
> over-general is what you asked for when reviewing it the first time.

Please give me some credit.  I mean that the code is difficult to
follow and justify when I say I don't understand it.  Yeah, I tried to
understand it and I think I understand how it *works* in its current
form but I just don't think the design is justified or logical.  You
say it's infeasible to do it in straightforward manner in reasonable
amount of time and that's why I neither acked or nacked the series and
deferred the decision to the subsystem maintainer.

But, at the very least, please add some comments.  Try to explain what
each callbacks are supposed to do and why they're there.  Not everyone
lives in your head.

Thanks.

-- 
tejun
