From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [patch net-next 2/4] net/sched: Introduce sample tc action
Date: Sun, 22 Jan 2017 09:29:50 -0500
Message-ID: <85vat7182p.fsf@mojatatu.com>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
        <1485085487-2652-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33917 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751254AbdAVO3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 09:29:55 -0500
Received: by mail-it0-f65.google.com with SMTP id o185so7648744itb.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 06:29:55 -0800 (PST)
In-Reply-To: <1485085487-2652-3-git-send-email-jiri@resnulli.us> (Jiri Pirko's
        message of "Sun, 22 Jan 2017 12:44:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> From: Yotam Gigi <yotamg@mellanox.com>
>
> This action allows the user to sample traffic matched by tc classifier.
> The sampling consists of choosing packets randomly and sampling them using
> the psample module. The user can configure the psample group number, the
> sampling rate and the packet's truncation (to save kernel-user traffic).
>

[skip]
> diff --git a/include/uapi/linux/tc_act/tc_sample.h b/include/uapi/linux/tc_act/tc_sample.h
> new file mode 100644
> index 0000000..21378bc
> --- /dev/null
> +++ b/include/uapi/linux/tc_act/tc_sample.h
> @@ -0,0 +1,26 @@
> +#ifndef __LINUX_TC_SAMPLE_H
> +#define __LINUX_TC_SAMPLE_H
> +
> +#include <linux/types.h>
> +#include <linux/pkt_cls.h>
> +#include <linux/if_ether.h>
> +
> +#define TCA_ACT_SAMPLE 26
> +
> +struct tc_sample {
> +	tc_gen;
> +};
> +
> +enum {
> +	TCA_SAMPLE_UNSPEC,
> +	TCA_SAMPLE_PARMS,
> +	TCA_SAMPLE_TM,
> +	TCA_SAMPLE_RATE,
> +	TCA_SAMPLE_TRUNC_SIZE,
> +	TCA_SAMPLE_PSAMPLE_GROUP,
> +	TCA_SAMPLE_PAD,
> +	__TCA_SAMPLE_MAX
> +};

Most of action implementations define TCA_X_TM attribute as 1,
and TCA_X_PARMS as 2 followed by action specific tlvs, it is better to
adhere this style in newly designed actions.

[skip]

-- 
Roman Mashak
