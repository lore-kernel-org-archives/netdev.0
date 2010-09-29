From: didier <did447@gmail.com>
Subject: Re: VLAN GARP triggers a lot of timers if linux compiled with VLAN_8021Q_GVRP
Date: Wed, 29 Sep 2010 13:02:02 +0200
Message-ID: <AANLkTimMTi-pHe7OYLV0=3m4KF35B+Scjf_HYZ8iiqLu@mail.gmail.com>
References: <AANLkTinZ_6+PzAHHc5vaY+H2iX_pf4vsdNsnZ2_N7EDf@mail.gmail.com>
	<4CA3056B.6010901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63159 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427Ab0I2LCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 07:02:04 -0400
Received: by bwz11 with SMTP id 11so411784bwz.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 04:02:02 -0700 (PDT)
In-Reply-To: <4CA3056B.6010901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
>
>> garp_join_timer_arm()
>>
>> delay = (u64)msecs_to_jiffies(garp_join_time)* net_random() >> 32;
>> mod_timer(&app->join_timer, jiffies +delay)
>>
>> Isn't this stuff triggering a *lot* of events?
>
> Yeah, something around 5-10 timers per second IIRC. There was an RFC
> patch a while ago to only schedule the timer on-demand, I'll see
> whether I can find it again.

But with this formula delay can be often rather small, or do I miss something?

Here on an idle box with two vlans vmstat output shows  burst of up to
15000 context switches per seconds.

Didier
