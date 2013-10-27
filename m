From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in bonding
Date: Sun, 27 Oct 2013 23:10:27 +0100
Message-ID: <20131027221027.GA11209@redhat.com>
References: <52688F33.30904@huawei.com>
 <20131027.163712.1324471504006808112.davem@davemloft.net>
 <20131027211048.GA557@redhat.com>
 <20131027.174458.627996500790326920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236Ab3J0WMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 18:12:46 -0400
Content-Disposition: inline
In-Reply-To: <20131027.174458.627996500790326920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 27, 2013 at 05:44:58PM -0400, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Sun, 27 Oct 2013 22:10:48 +0100
>
>> All the changelogs for the patches are *the same*, and, while they try
>> to
>> explain what's done overall, the don't explain what's done per-patch,
>> why
>> it's done and why is it safe to move those locks around.
>
>He did say so, he listed in fact three alternative ways to fix the
>locking problem and then explciitly stated which of the three he
>choose.

He just rephrased me - http://www.spinics.net/lists/netdev/msg254618.html .

And still the patches didn't say how he did it and why is it safe/good to
do it the way he did it. That's, basically, code without commit messages,
which touches really sensitive parts. As I've said in the above link, it's
really hard to review them this way.

>
>I would have preferred that he did all of this in the initial 0/N
>patch posting, but I can't defer forever.

Maybe I'm too picky. Anyway - understood, thanks.
