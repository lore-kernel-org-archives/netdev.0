From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/7] devlink: Add permanent config parameter get/set
 operations
Date: Wed, 18 Oct 2017 14:58:25 +0200
Message-ID: <20171018125825.GA1975@nanopsycho.orion>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-2-git-send-email-steven.lin1@broadcom.com>
 <20171018071140.GB2028@nanopsycho>
 <CA+Jmh7FRAAYyQv=qecU6RHFc_yj5P6Kp=8nB41i0driu9gycOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:52910 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752275AbdJRM61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 08:58:27 -0400
Received: by mail-wm0-f48.google.com with SMTP id k4so10076147wmc.1
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 05:58:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Jmh7FRAAYyQv=qecU6RHFc_yj5P6Kp=8nB41i0driu9gycOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 18, 2017 at 02:39:09PM CEST, steven.lin1@broadcom.com wrote:
>On Wed, Oct 18, 2017 at 3:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Oct 17, 2017 at 10:44:23PM CEST, steven.lin1@broadcom.com wrote:
>> Steve. As I originally requested, could you please split this to:
>> 1) single patch adding config get/set commands, without any config attributes
>> 2) single patch per config attribute - please don't add them in bulk.
>>    We also need very strict description for every single attribute so
>>    other vendors know what it is and can re-use it. There is need to
>>    avoid duplication here. Also, please send just few attribites in the
>>    first run, not like 40 you are sending now. Impossible to review.
>
>I broke the patch set up into functional blocks of attributes, in
>order to avoid having ~40 patches of just a couple lines each.  But, I
>will split further for each individual attribute, and just submit a
>few initially, per your request.
>
>>
>> Also, why didn't you put it into nested attribute we were discussing?
>>
>
>I thought I did :) , using the DPIPE_HEADERS nested attribute as an
>example.  I'll reach out to you off-list to understand what I'm
>missing.

I missed that. But you need a separate attr enum as well.
