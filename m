From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/3] team: add peer notification
Date: Fri, 19 Jul 2013 16:02:29 +0200
Message-ID: <20130719140229.GD1642@minipsycho.orion>
References: <1374241222-9683-1-git-send-email-jiri@resnulli.us>
 <1374241222-9683-2-git-send-email-jiri@resnulli.us>
 <1374242210.26476.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net, stephen@networkplumber.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:44598 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759785Ab3GSOCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 10:02:34 -0400
Received: by mail-ea0-f178.google.com with SMTP id l15so2374388eak.23
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 07:02:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1374242210.26476.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 19, 2013 at 03:56:50PM CEST, eric.dumazet@gmail.com wrote:
>On Fri, 2013-07-19 at 15:40 +0200, Jiri Pirko wrote:
>> When port is enabled or disabled, allow to notify peers by unsolicitated
>> NAs or gratuitous ARPs. Disabled by default.
>> 
>
>> +	if (!atomic_dec_and_test(&team->notify_peers.count_pending))
>> +		schedule_delayed_work(&team->notify_peers.dw,
>> +				      (team->notify_peers.interval * HZ) / 1000);
>
>Isn't that msecs_to_jiffies() ?

It is - I will change it (in loadbalance mode as well) and repost.
Thanks

>
>
>
