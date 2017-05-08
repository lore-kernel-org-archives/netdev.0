From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next v2 3/4] net/sched: cls_flower: do not match
 if dissection fails
Date: Mon, 8 May 2017 07:26:31 -0400
Message-ID: <20bc02eb-ea99-652e-7205-fa6131964446@mojatatu.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
 <1493988426-22854-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>
To: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33613 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752105AbdEHL0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 07:26:34 -0400
Received: by mail-it0-f65.google.com with SMTP id v135so6979741itv.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 04:26:34 -0700 (PDT)
In-Reply-To: <1493988426-22854-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-05 08:47 AM, Simon Horman wrote:
> If the flow skb_flow_dissect() returns an error it indicates that
> dissection was incomplete for some reason. Matching using the result of an
> incomplete dissection may cause unexpected results. For example:
>
> * A match on zero layer 4 ports will also match packets truncated at
>   the end of the IP header; that is packets where ports are missing are
>   treated the same way as packets with zero ports.
> * Likewise, a match on zero ICMP code or type will also match packets
>   truncated at the end of the IP header; that is packets where the ICMP
>   type and code are missing will be treated the same way as packets with
>   zero ICMP code and type.
>
> Separate patches to the flow dissector are required in order for it to
> return errors in the above cases.
>
> Fixes: 77b9900ef53a ("tc: introduce Flower classifier")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
