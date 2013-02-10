From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 08/11] tbf: fix value set for q->ptokens
Date: Sun, 10 Feb 2013 19:37:32 +0100
Message-ID: <20130210183732.GB1602@minipsycho.orion>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
 <1360428312-1277-9-git-send-email-jiri@resnulli.us>
 <1360459846.20362.2.camel@edumazet-glaptop>
 <20130210081824.GA1570@minipsycho.orion>
 <1360484498.20362.12.camel@edumazet-glaptop>
 <20130210085155.GB1570@minipsycho.orion>
 <1360519208.20362.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:53793 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463Ab3BJShl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 13:37:41 -0500
Received: by mail-ea0-f176.google.com with SMTP id a13so2466829eaa.35
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 10:37:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360519208.20362.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 10, 2013 at 07:00:08PM CET, eric.dumazet@gmail.com wrote:
>On Sun, 2013-02-10 at 09:51 +0100, Jiri Pirko wrote:
>> Sun, Feb 10, 2013 at 09:21:38AM CET, eric.dumazet@gmail.com wrote:
>> >On Sun, 2013-02-10 at 09:18 +0100, Jiri Pirko wrote:
>> >> Sun, Feb 10, 2013 at 02:30:46AM CET, eric.dumazet@gmail.com wrote:
>> >> >On Sat, 2013-02-09 at 17:45 +0100, Jiri Pirko wrote:
>> >> >> q->ptokens is in ns and we are assigning q->mtu directly to it. That is
>> >> >> wrong. psched_l2t_ns() should be used to compute correct value.
>> >> >> 
>> >> >
>> >> >
>> >> >Not clear why its a separate patch, and not folded in the 6th
>> >> 
>> >> This is independent on 6th. Would be needed even if 6th wouldn't be
>> >> there.
>> >
>> >When was this bug introduced then ?
>> 
>> This has been present since the beginning of git. I'm unable to find bk
>> repo right now to tell you bk commit :/
>
>Current code doesnt store ptokens in ns, your patch is very confusing.
>
>q->mtu is properly setup by tc command.

Now I get it. q->mtu is not bytes but time instead. I will fix my patches.

>
>Its not dev->mtu at all.
>
>I claim you fix a bug added in 6th patch.
>
>It makes no sense to me to introduce a bug in 6th and fix it in 8th.
>
>
>
