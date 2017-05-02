From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next repost] net: sched: add helpers to handle
 extended actions
Date: Tue, 2 May 2017 07:59:20 -0400
Message-ID: <35328c1b-4571-f115-50c6-5f0c46ced3cc@mojatatu.com>
References: <1493712720-1501-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35883 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdEBL7W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 07:59:22 -0400
Received: by mail-it0-f67.google.com with SMTP id x188so1835150itb.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 04:59:22 -0700 (PDT)
In-Reply-To: <1493712720-1501-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-02 04:12 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Jump is now the only one using value action opcode. This is going to
> change soon. So introduce helpers to work with this. Convert TC_ACT_JUMP.
>
> This also fixes the TC_ACT_JUMP check, which is incorrectly done as a
> bit check, not a value check.
>
> Fixes: e0ee84ded796 ("net sched actions: Complete the JUMPX opcode")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> Dave, I'm sending this for -net-next although I know it is closed. But
> the mentioned commit is not yet in -net. Feel free to take this either
> to -net-next or -net, whatever suits you better. Thanks.

I think you are pushing the boundary a little calling it a bug fix
and this could go with your patch series instead.
The name TC_ACT_EXT_CMP should be TC_ACT_EXT_CMP_OPCODE
Other than that:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
