From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 6/6] net_sched: cls_cgroup: remove unnecessary if
Date: Wed, 3 Dec 2014 15:39:13 +0100
Message-ID: <20141203143913.GJ1860@nanopsycho.orion>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
 <1417539636-12710-7-git-send-email-jiri@resnulli.us>
 <547F0AFA.7090001@mojatatu.com>
 <20141203131815.GF1860@nanopsycho.orion>
 <547F1E98.1050704@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34966 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbaLCOjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 09:39:18 -0500
Received: by mail-wg0-f46.google.com with SMTP id a1so11748588wgh.19
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 06:39:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547F1E98.1050704@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 03, 2014 at 03:30:48PM CET, jhs@mojatatu.com wrote:
>On 12/03/14 08:18, Jiri Pirko wrote:
>
>>>
>>>Hrm. head could be NULL, no?
>>
>>Sure it can. But that is not a problem. Not sure what you are trying to
>>point at...
>>
>
>I suppose head->handle MUST always be equal to handle for the change to
>work. So doesnt matter if handle is null or not. Too clever for me.

Exactly. That is what I tried to say in patch desc :)

>
>Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>cheers,
>jamal
