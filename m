From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 04/20] net: sched: use tcf_exts_has_actions in
 tcf_exts_exec
Date: Mon, 31 Jul 2017 08:09:22 -0400
Message-ID: <01a0f827-1a9d-d8fa-f2b1-1c3ab65c4352@mojatatu.com>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-5-jiri@resnulli.us>
 <c157148b-2e6c-6934-2d54-04d42a0a262c@mojatatu.com>
 <20170731063613.GA1883@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:34687 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750987AbdGaMJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 08:09:25 -0400
Received: by mail-it0-f51.google.com with SMTP id m34so723890iti.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 05:09:25 -0700 (PDT)
In-Reply-To: <20170731063613.GA1883@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-31 02:36 AM, Jiri Pirko wrote:
> Sun, Jul 30, 2017 at 09:48:24PM CEST, jhs@mojatatu.com wrote:
>> I am probably missing something. All those changes to just
>> replace "if (exts->nr_actions)" with "if (tcf_exts_has_actions(exts))" ?
> 
> That is what the description says :)
> 

I meant I wouldve expected few liners added/removed.

cheers,
jamal
