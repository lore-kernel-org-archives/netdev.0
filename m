From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud filters
 in i40e
Date: Wed, 11 Oct 2017 23:28:57 +0200
Message-ID: <20171011212857.GE9297@nanopsycho>
References: <20171011203832.GA9297@nanopsycho>
 <20171011.134652.1653141099248918341.davem@davemloft.net>
 <20171011205830.GD9297@nanopsycho>
 <20171011.141929.2232480660433567821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.duyck@gmail.com, amritha.nambiar@intel.com,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:46356 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750718AbdJKV27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:28:59 -0400
Received: by mail-wm0-f45.google.com with SMTP id m72so8373596wmc.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:28:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171011.141929.2232480660433567821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 11, 2017 at 11:19:29PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 11 Oct 2017 22:58:30 +0200
>
>> Well if I see classid, I expect it should refer to qdisc instance. So
>> far, this has been always a case. But for some drivers, this would mean
>> something totally different and unrelated. So what should I think?
>> What's next? Classid could be abused to identify something else. I don't
>> understand why.
>> 
>> classid in kernel and tclass in hw are 2 completely unrelated things.
>
>Why do they need to be different?
>
>It's qdisc instance in both cases.  The driver is just using it to
>refer to the qdisc as offloaded in the hardware.  It's a key, nothing
>more.  The context in which it is used doesn't change it's meaning.
>
>> Why they should share the same userspace api? What am I missing that
>> indicates this is not an abuse?
>
>Why invent a completely new ID space to refer to something we exactly
>have an ID for already?
>
>This duplication for the sake of "API" makes no sense to me.
>
>The handle is not going away.  It is not going to stop referring to
>a specific qdisc.
>
>So it's stable and appropriate to use to refer to a qdisc, whatever
>operation being performed, or offload being we are going to perform of
>it.

Okay, fair enough. Yet, I can't say I'm happy with it :/ But I guess
that what you say makes sense.


>
>I notice you are quite feisty lately in your reviews of other people's
>work, so I have to ask if things are very stressful in your life?

:) Yeah, that is probably coincidental. Lots of odd offloading stuff is
happening lately.


>Please drink a nice warm cup of tea and calm down :-)

I'm perfectly calm. But thanks for showing the care :)
