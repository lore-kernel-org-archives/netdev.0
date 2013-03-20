From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Wed, 20 Mar 2013 18:18:07 -0400 (EDT)
Message-ID: <20130320.181807.147847609140930081.davem@davemloft.net>
References: <CAE9FiQX+9NXfVO9P1ZELYjA+D35Tt7r0ngsGZfW9VaU1Q0WJvQ@mail.gmail.com>
	<20130320.181005.1507999596274688798.davem@davemloft.net>
	<CAE9FiQVJhAbvfxp152a0KbzFE1hVQZMNwdWkKnyii3HNWDBd=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rui.zhang@intel.com, yamato@redhat.com, netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab3CTWSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 18:18:08 -0400
In-Reply-To: <CAE9FiQVJhAbvfxp152a0KbzFE1hVQZMNwdWkKnyii3HNWDBd=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>
Date: Wed, 20 Mar 2013 15:17:13 -0700

> On Wed, Mar 20, 2013 at 3:10 PM, David Miller <davem@davemloft.net> wrote:
> 
>>> so bisecting will be broken?
>>
>> Good point, so I'll apply the thermal patch to my tree to minimize
>> the failure range.
> 
> yes, that "second" patch should be applied before this one.

But it's too late as the first one is already commited to my public
GIT tree on kernel.org and I never rebase my tree, ever.

So this is the only option to minimize the damage at this point.
