From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] net: add a core netdev->rx_dropped counter
Date: Mon, 4 Oct 2010 13:27:40 -0700
Message-ID: <AANLkTimcmdjk+gCN=w=gMgCDSvK8G7LFL_s2TXovjMoG@mail.gmail.com>
References: <20100929113757.GA23755@core.hellgate.ch>
	<AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	<20100930080703.GA10827@core.hellgate.ch>
	<AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
	<1285884253.2705.25.camel@edumazet-laptop>
	<AANLkTi=Vdcn7xzJMPxkugvEVy32N7Bp=KVtir6NESnDF@mail.gmail.com>
	<1285909831.2705.41.camel@edumazet-laptop>
	<1285916815.2705.152.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Roger Luethi <rl@hellgate.ch>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:47748 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757063Ab0JDU1m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 16:27:42 -0400
Received: by iwn5 with SMTP id 5so7338998iwn.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 13:27:41 -0700 (PDT)
In-Reply-To: <1285916815.2705.152.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 1, 2010 at 12:06 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 01 octobre 2010 =E0 07:10 +0200, Eric Dumazet a =E9crit :
>
>> This seems very reasonable ;)
>>
>> I'll add a counter, a core generalization of
>> commit 8990f468a (net: rx_dropped accounting)
>>
>> Because we can drop packets _after_ netif_rx() if RPS is in action
>> anyway.
>>
>>
>
> In this patch I fold the additional dev->rx_dropped into get_stats()
> structure. We might chose to not fold it, and provides this counter i=
n a
> new /proc/net/dev column, a new rtnetlink attribute (and appropriate
> iproute2 change)
>
> What do you think ?

This patch makes sense to me.  I think combining the dropped stats
with those from the driver makes sense, at least at the moment, since
both the counters from both sources are from a combination of
different causes anyways.
