From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/4] net/sched: Introduce sample tc action
Date: Sun, 22 Jan 2017 08:16:38 -0500
Message-ID: <52d57d84-6e0d-0ff3-5027-6dea06f4a683@mojatatu.com>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
 <1485085487-2652-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        geert+renesas@glider.be, stephen@networkplumber.org,
        xiyou.wangcong@gmail.com, linux@roeck-us.net,
        roopa@cumulusnetworks.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34078 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdAVNQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 08:16:40 -0500
Received: by mail-qk0-f196.google.com with SMTP id e1so7626904qkh.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 05:16:40 -0800 (PST)
In-Reply-To: <1485085487-2652-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-22 06:44 AM, Jiri Pirko wrote:

> diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
> new file mode 100644
> index 0000000..24e20e4
> --- /dev/null
> +++ b/net/sched/act_sample.c
> @@ -0,0 +1,274 @@
> +/*
> + * net/sched/act_sample.c - Packet samplig tc action

typo: "Sampling"


> +static int tcf_sample(struct sk_buff *skb, const struct tc_action *a,
> +		      struct tcf_result *res)


Can you rename this function because it is also the name of the data
structure? It makes it easier to grep.
I know we have this all over the place in other actions (and i hope
those are cleaned up at some point).

otherwise:
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
