From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Tue, 10 Feb 2009 00:36:06 +0100
Message-ID: <4990BDE6.80102@trash.net>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet>	<20090209.143238.25276576.davem@davemloft.net>	<4990B26B.3020705@trash.net> <20090209.151806.02424601.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34588 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbZBIXgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 18:36:10 -0500
In-Reply-To: <20090209.151806.02424601.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 09 Feb 2009 23:47:07 +0100
> 
>> David Miller wrote:
>>> From: Patrick McHardy <kaber@trash.net>
>>> Date: Mon,  9 Feb 2009 17:39:27 +0100 (MET)
>>>
>>>> Please apply or pull from:
>>>>
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git
>>> I was going to pull from your tree and take it like that, but when I
>>> pulled I got 5 real changes and 50 merges with net-2.6, yikes! :-)
>> Ugh sorry, thats happening automatically, but it usually doesn't show
>> up since it should be fast forwards. I'll have a look at what went
>> wrong.
> 
> I think you got a change into your tree locally, this went via net-2.6
> and thereafterwards it started using merges.  But that's just a guess.

Yes, probably, although I really never commit to my mirrored trees.
It might have something to do with my disk dying last week and the
restore I did :)

> Want some suggestions for work flow? :-)
> 
> 1) For net-2.6 just clone Linus's tree, pull net-2.6 once as it is
>    right now, then leave it alone.
> 
>    Periodically sync your origin (which is Linus's tree) via
>    "git fetch origin".  This just grabs the objects.
> 
>    Then you can just go "git request-pull origin $(GIT_URL)" and
>    it'll just work.
> 
>    Since the likelyhood for conflicts in the net-2.6 tree with
>    your netfilter work is incredibly unlikely, doing a merge
>    should never be necessary.  But if it is just go
>    "git pull origin".
> 
> 2) For net-next-2.6 use net-next-2.6 as your "origin" (you can change
>    this in .git/config), conflicts are more likely so every once in
>    a while a "git pull origin" will be necessary.
> 
> If that doesn't work out or feel comfortable for you, that's
> fine.

I'll try that, maybe starting with net-2.6 since that tree is
easier to maintain for me. My workflow is quite out of sync
with modern git commands, some of my scripts are still adapted
from bitkeeper times :)


