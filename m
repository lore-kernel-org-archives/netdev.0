From: Zdenek Kabelac <zkabelac@redhat.com>
Subject: Re: [BUG] INFO: inconsistent lock state
Date: Tue, 06 Jan 2009 11:47:00 +0100
Message-ID: <496336A4.4020109@redhat.com>
References: <4962C322.8000201@cn.fujitsu.com> <49633005.5080305@redhat.com> <4963319D.8040204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48820 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862AbZAFKrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 05:47:06 -0500
In-Reply-To: <4963319D.8040204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Zefan napsal(a):
> Zdenek Kabelac wrote:
>> Li Zefan napsal(a):
>>> I am using Linus' tree, and the top commit is:
>>>
>>> commit fe0bdec68b77020281dc814805edfe594ae89e0f
>>> Merge: 099e657... 5af75d8...
>>> Author: Linus Torvalds <torvalds@linux-foundation.org>
>>> Date:   Sun Jan 4 16:32:11 2009 -0800
>>>
>>>     Merge branch 'audit.b61' of
>>> git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
>>>
>>> don't know how I triggered this, and not sure whom to CC, network
>>> related?
>>>
>> I've got the similar one too: http://lkml.org/lkml/2009/1/3/55
>>
> 
> So your box freezed and can do nothing but reset ?
> 
> I was much luckier that this bug didn't do any harm to my box. :)

Well the problem was that at the same time it has probably crashed my Xorg 
server (with some recent rawhide version) and this might have been the reason 
of hard crash as well - I'm not sure what was the exact order.

Zdenek

