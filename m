From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Fri, 13 Sep 2013 18:32:52 -0700
Message-ID: <87fvt8tcfv.fsf@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<20130913.201626.1381750756413200302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:48016 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755913Ab3INBdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 21:33:00 -0400
In-Reply-To: <20130913.201626.1381750756413200302.davem@davemloft.net> (David
	Miller's message of "Fri, 13 Sep 2013 20:16:26 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 12 Sep 2013 13:06:53 -0700
>
>> David, Eric, do any of you know why we have this netdevice notfier
>> rebroadcast?
>
> It's been there as long as I can remember, but I don't remember
> exactly why we do that.
>
> If I had to guess, it's to handle something that has to retry later
> due to a "spin_trylock()" or similar type of situation.
>
> Probably best to not remove it. :)

Since it doesn't completely solve the problem, it isn't worth it to
solve this problem.  Sigh

I have added this bit of code and the moving of references to the
loopback device in dst_ifdown to my hitlist of things to sort out some
day when I have plenty time.

Eric
