From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH v3 net-next] net: pkt_sched: PIE AQM scheme
Date: Sat, 2 Nov 2013 22:38:03 -0700
Message-ID: <CAGK4HS-3r77+dk=k78WFC_ppg3cTgR+MwwDX2+Uuqrwb2K_V5w@mail.gmail.com>
References: <1383338722-6000-1-git-send-email-subramanian.vijay@gmail.com>
	<1383353798.4291.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Mythili Prabhu <mysuryan@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:47163 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab3KCFiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 01:38:06 -0400
Received: by mail-vc0-f180.google.com with SMTP id lc6so3829460vcb.39
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 22:38:05 -0700 (PDT)
In-Reply-To: <1383353798.4291.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the reviews, Eric.

>> +
>> +             return qdisc_enqueue_tail(skb, sch);
>
> I am not sure why you mix skb->len and qdisc_len(skb)

I will refactor the code to update the stats more cleanly.

>
> Also, a default 200 packets limit sounds strange, was it actually tested
> on a 10Gb link ?
>
No. It was tested on 1 Gbps link. Increasing limit to a default of
1000 should be fine.
I will send v4 after some tests to make sure nothing breaks.

Thanks,
Vijay
