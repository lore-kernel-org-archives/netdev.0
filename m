From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next repost] net: sched: add helpers to handle
 extended actions
Date: Tue, 2 May 2017 14:07:54 +0200
Message-ID: <20170502120754.GD1877@nanopsycho.orion>
References: <1493712720-1501-1-git-send-email-jiri@resnulli.us>
 <35328c1b-4571-f115-50c6-5f0c46ced3cc@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34067 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbdEBMH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 08:07:57 -0400
Received: by mail-wr0-f194.google.com with SMTP id 6so17002781wrb.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 05:07:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <35328c1b-4571-f115-50c6-5f0c46ced3cc@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 02, 2017 at 01:59:20PM CEST, jhs@mojatatu.com wrote:
>On 17-05-02 04:12 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Jump is now the only one using value action opcode. This is going to
>> change soon. So introduce helpers to work with this. Convert TC_ACT_JUMP.
>> 
>> This also fixes the TC_ACT_JUMP check, which is incorrectly done as a
>> bit check, not a value check.
>> 
>> Fixes: e0ee84ded796 ("net sched actions: Complete the JUMPX opcode")
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> Dave, I'm sending this for -net-next although I know it is closed. But
>> the mentioned commit is not yet in -net. Feel free to take this either
>> to -net-next or -net, whatever suits you better. Thanks.
>
>I think you are pushing the boundary a little calling it a bug fix

Well, it is a bugfix. Otherwise we could not use bit 1 for anything else
then jump in the future. This is also UAPI. That's why I'm pushing it as
a fix.

>and this could go with your patch series instead.
>The name TC_ACT_EXT_CMP should be TC_ACT_EXT_CMP_OPCODE

I was thinking about it as well, I would like to keep it shorter. The
current name is quite appropriate and it is clear what the macro does.


>Other than that:
>
>Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
 
Thanks.
