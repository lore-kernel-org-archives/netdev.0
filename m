From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 08:55:57 -0400
Message-ID: <85shl4o8te.fsf@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
        <20170419123645.GB3357@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, eric.dumazet@gmail.com,
        xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34502 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762923AbdDSM4C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 08:56:02 -0400
Received: by mail-it0-f67.google.com with SMTP id 193so2617992itm.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 05:56:01 -0700 (PDT)
In-Reply-To: <20170419123645.GB3357@nanopsycho.orion> (Jiri Pirko's message of
        "Wed, 19 Apr 2017 14:36:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:


[...]

>>+enum {
>>+	TCAA_UNSPEC,
>>+	TCAA_ACT_TAB,
>>+	TCAA_ACT_FLAGS,
>>+	TCAA_ACT_COUNT,
>>+	__TCAA_MAX
>>+};
>>+
>>+#define TCAA_MAX (__TCAA_MAX - 1)
>> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>>-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>>-#define TCAA_MAX 1
>>+#define TCA_ACT_TAB TCAA_ACT_TAB
>
> This is mess. What does "TCAA" stand for?
> I suggest some more meaningful naming of the enum items and define
> TCA_ACT_TAB and TCAA_MAX to the new values in order to maintain UAPI
> Also, please put X_MAX = __X_MAX - 1 into enum
>

Notation observed in tc and unfortunately not consistently maintained is
to have enum with TCA* attributes for instance, followed by define,
outside of the enum, with __X_MAX -1

[...]
