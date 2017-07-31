From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 04/20] net: sched: use tcf_exts_has_actions in
 tcf_exts_exec
Date: Mon, 31 Jul 2017 08:36:13 +0200
Message-ID: <20170731063613.GA1883@nanopsycho>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-5-jiri@resnulli.us>
 <c157148b-2e6c-6934-2d54-04d42a0a262c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:32893 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751954AbdGaGgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 02:36:16 -0400
Received: by mail-wr0-f193.google.com with SMTP id y43so30681545wrd.0
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 23:36:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c157148b-2e6c-6934-2d54-04d42a0a262c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 30, 2017 at 09:48:24PM CEST, jhs@mojatatu.com wrote:
>I am probably missing something. All those changes to just
>replace "if (exts->nr_actions)" with "if (tcf_exts_has_actions(exts))" ?

That is what the description says :)


>
>cheers,
>jamal
>
>On 17-07-28 10:40 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Use the tcf_exts_has_actions helper instead or directly testing
>> exts->nr_actions in tcf_exts_exec.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
