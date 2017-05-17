From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 10/10] net: sched: add termination action to
 allow goto chain
Date: Wed, 17 May 2017 08:31:31 -0400
Message-ID: <c53d144f-9b49-2832-d0c4-326cc1d6fed0@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-11-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35024 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753296AbdEQMbd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:31:33 -0400
Received: by mail-it0-f65.google.com with SMTP id 67so1335080itx.2
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:31:33 -0700 (PDT)
In-Reply-To: <20170517090803.4461-11-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:08 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Introduce new type of termination action called "goto_chain". This allows
> user to specify a chain to be processed. This action type is
> then processed as a return value in tcf_classify loop in similar
> way as "reclassify" is, only it does not reset to the first filter
> in chain but rather reset to the first filter of the desired chain.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
