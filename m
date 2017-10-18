From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/7] devlink: Add permanent config parameter get/set
 operations
Date: Wed, 18 Oct 2017 16:01:03 +0200
Message-ID: <20171018140103.GD1975@nanopsycho.orion>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-2-git-send-email-steven.lin1@broadcom.com>
 <20171018071140.GB2028@nanopsycho>
 <CA+Jmh7FRAAYyQv=qecU6RHFc_yj5P6Kp=8nB41i0driu9gycOQ@mail.gmail.com>
 <20171018125825.GA1975@nanopsycho.orion>
 <CA+Jmh7Etbr_E-E35fY79s4ss+nsgH4+wN=RQiK4WCcP-XXe1Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:49691 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753647AbdJROBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:01:05 -0400
Received: by mail-wr0-f194.google.com with SMTP id g90so5139919wrd.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:01:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Jmh7Etbr_E-E35fY79s4ss+nsgH4+wN=RQiK4WCcP-XXe1Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 18, 2017 at 03:14:35PM CEST, steven.lin1@broadcom.com wrote:
>On Wed, Oct 18, 2017 at 8:58 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Oct 18, 2017 at 02:39:09PM CEST, steven.lin1@broadcom.com wrote:
>>>On Wed, Oct 18, 2017 at 3:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Tue, Oct 17, 2017 at 10:44:23PM CEST, steven.lin1@broadcom.com wrote:
>>>> Steve. As I originally requested, could you please split this to:
>>>> 1) single patch adding config get/set commands, without any config attributes
>>>> 2) single patch per config attribute - please don't add them in bulk.
>>>>    We also need very strict description for every single attribute so
>>>>    other vendors know what it is and can re-use it. There is need to
>>>>    avoid duplication here. Also, please send just few attribites in the
>>>>    first run, not like 40 you are sending now. Impossible to review.
>>>
>>>I broke the patch set up into functional blocks of attributes, in
>>>order to avoid having ~40 patches of just a couple lines each.  But, I
>>>will split further for each individual attribute, and just submit a
>>>few initially, per your request.
>>>
>>>>
>>>> Also, why didn't you put it into nested attribute we were discussing?
>>>>
>>>
>>>I thought I did :) , using the DPIPE_HEADERS nested attribute as an
>>>example.  I'll reach out to you off-list to understand what I'm
>>>missing.
>>
>> I missed that. But you need a separate attr enum as well.
>>
>
>I did have this as the nested attr enum in the original patch:

No, I mean separate "enum your_new_enum"


>
>        /* Permanent Configuration Parameters */
>        DEVLINK_ATTR_PERM_CFG,                          /* nested */
>
>However, I only used the nested construct in the response from kernel
>to userspace, not in the request from userspace to kernel.  (This was
>based on looking at the various DPIPE_* nested attributes as
>examples.)
>
>Thinking about it after seeing your comment, I'm thinking I should
>also use the nested attribute construct in the original request from
>userspace to kernel as well, although I didn't see any previous
>examples of this in devlink.
>
>So I'll plan to use nesting in that direction as well.
>
>Thanks,
>Steve
