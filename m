From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix compat recvmsg
Date: Wed, 18 Aug 2010 23:36:23 -0700 (PDT)
Message-ID: <20100818.233623.13755519.davem@davemloft.net>
References: <1281940172.2942.81.camel@edumazet-laptop>
	<1281943244.3683.8.camel@jlt3.sipsolutions.net>
	<1281963025.2524.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	kalle.valo@iki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47331
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066Ab0HSGgE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 02:36:04 -0400
In-Reply-To: <1281963025.2524.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Aug 2010 14:50:25 +0200

> Le lundi 16 ao=FBt 2010 =E0 09:20 +0200, Johannes Berg a =E9crit :
>> From: Johannes Berg <johannes.berg@intel.com>
>>=20
>> Since
>> commit 1dacc76d0014a034b8aca14237c127d7c19d7726
>> Author: Johannes Berg <johannes@sipsolutions.net>
>> Date:   Wed Jul 1 11:26:02 2009 +0000
>>=20
>>     net/compat/wext: send different messages to compat tasks
>>=20
>> we had a race condition when setting and then
>> restoring frag_list. Eric attempted to fix it,
>> but the fix created even worse problems.
 ...
>> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks guys!
