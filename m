From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 08/11] tbf: fix value set for q->ptokens
Date: Sun, 10 Feb 2013 09:51:55 +0100
Message-ID: <20130210085155.GB1570@minipsycho.orion>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
 <1360428312-1277-9-git-send-email-jiri@resnulli.us>
 <1360459846.20362.2.camel@edumazet-glaptop>
 <20130210081824.GA1570@minipsycho.orion>
 <1360484498.20362.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:61643 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab3BJIwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 03:52:00 -0500
Received: by mail-ee0-f53.google.com with SMTP id e53so2643758eek.26
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 00:51:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360484498.20362.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 10, 2013 at 09:21:38AM CET, eric.dumazet@gmail.com wrote:
>On Sun, 2013-02-10 at 09:18 +0100, Jiri Pirko wrote:
>> Sun, Feb 10, 2013 at 02:30:46AM CET, eric.dumazet@gmail.com wrote:
>> >On Sat, 2013-02-09 at 17:45 +0100, Jiri Pirko wrote:
>> >> q->ptokens is in ns and we are assigning q->mtu directly to it. That is
>> >> wrong. psched_l2t_ns() should be used to compute correct value.
>> >> 
>> >
>> >
>> >Not clear why its a separate patch, and not folded in the 6th
>> 
>> This is independent on 6th. Would be needed even if 6th wouldn't be
>> there.
>
>When was this bug introduced then ?

This has been present since the beginning of git. I'm unable to find bk
repo right now to tell you bk commit :/
>
>
