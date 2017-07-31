From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 04/20] net: sched: use tcf_exts_has_actions in
 tcf_exts_exec
Date: Mon, 31 Jul 2017 14:23:20 +0200
Message-ID: <20170731122320.GE1883@nanopsycho>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-5-jiri@resnulli.us>
 <c157148b-2e6c-6934-2d54-04d42a0a262c@mojatatu.com>
 <20170731063613.GA1883@nanopsycho>
 <01a0f827-1a9d-d8fa-f2b1-1c3ab65c4352@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35510 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdGaMXW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 08:23:22 -0400
Received: by mail-wr0-f194.google.com with SMTP id c24so27867289wra.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 05:23:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <01a0f827-1a9d-d8fa-f2b1-1c3ab65c4352@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 31, 2017 at 02:09:22PM CEST, jhs@mojatatu.com wrote:
>On 17-07-31 02:36 AM, Jiri Pirko wrote:
>> Sun, Jul 30, 2017 at 09:48:24PM CEST, jhs@mojatatu.com wrote:
>> > I am probably missing something. All those changes to just
>> > replace "if (exts->nr_actions)" with "if (tcf_exts_has_actions(exts))" ?
>> 
>> That is what the description says :)
>> 
>
>I meant I wouldve expected few liners added/removed.

one actually. But the function tcf_exts_exec had to be moved since
tcf_exts_has_actions was defined after originaly

>
>cheers,
>jamal
