From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 1/4] net: Introduce psample, a new genetlink
 channel for packet sampling
Date: Sun, 22 Jan 2017 08:19:35 -0500
Message-ID: <9f5b46ff-2bc1-7b28-e13a-625bc495496f@mojatatu.com>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
 <1485085487-2652-2-git-send-email-jiri@resnulli.us>
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
Received: from mail-qt0-f194.google.com ([209.85.216.194]:32773 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751615AbdAVNTi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 08:19:38 -0500
Received: by mail-qt0-f194.google.com with SMTP id n13so11350690qtc.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 05:19:38 -0800 (PST)
In-Reply-To: <1485085487-2652-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-22 06:44 AM, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
>
> Add a general way for kernel modules to sample packets, without being tied
> to any specific subsystem. This netlink channel can be used by tc,
> iptables, etc. and allow to standardize packet sampling in the kernel.
>
> For every sampled packet, the psample module adds the following metadata
> fields:
>
> PSAMPLE_ATTR_IIFINDEX - the packets input ifindex, if applicable
>
> PSAMPLE_ATTR_OIFINDEX - the packet output ifindex, if applicable
>
> PSAMPLE_ATTR_ORIGSIZE - the packet's original size, in case it has been
>    truncated during sampling
>
> PSAMPLE_ATTR_SAMPLE_GROUP - the packet's sample group, which is set by the
>    user who initiated the sampling. This field allows the user to
>    differentiate between several samplers working simultaneously and
>    filter packets relevant to him
>
> PSAMPLE_ATTR_GROUP_SEQ - sequence counter of last sent packet. The
>    sequence is kept for each group
>
> PSAMPLE_ATTR_SAMPLE_RATE - the sampling rate used for sampling the packets
>
> PSAMPLE_ATTR_DATA - the actual packet bits
>
> In addition, add the GET_GROUPS netlink command which allows the user to
> see the current sample groups, their refcount and sequence number. This
> command currently supports only netlink dump mode.
>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Will be useful to describe in the commit log that one needs to listen
to PSAMPLE_NL_MCGRP_SAMPLE to see the samples.

Reviewed-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
