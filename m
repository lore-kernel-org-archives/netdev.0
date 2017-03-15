From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Wed, 15 Mar 2017 18:14:02 +0200
Message-ID: <CAJ3xEMiF_T_JxTik+yxvYoBQCiG=kKzukSsORApKB9nhTSvqeQ@mail.gmail.com>
References: <635223204.206529.1487859673545.JavaMail.zimbra@tpip.net>
 <20170223164229.GA4996@salvia> <109485900.208950.1487870356640.JavaMail.zimbra@tpip.net>
 <20170223.125401.1794857404908689667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andreas Schultz <aschultz@tpip.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f182.google.com ([74.125.82.182]:34738 "EHLO
        mail-ot0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdCOQOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 12:14:04 -0400
Received: by mail-ot0-f182.google.com with SMTP id o24so23977898otb.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 09:14:03 -0700 (PDT)
In-Reply-To: <20170223.125401.1794857404908689667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 7:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Andreas Schultz <aschultz@tpip.net>
> Date: Thu, 23 Feb 2017 18:19:16 +0100 (CET)
>
>> When we are talking about the xmit path, then currently none of the
>> receivers we are talking to is going to be Linux and we have no
>> idea how they will behave nor do we have any influence on them. Do
>> we really need to make assumptions about other vendors implementations?
>>
>> Traces on live GRX networks show that about 90% of the SGSN/S-GW
>> that would talk to us always use the default GTP-U port as source
>> port. Some multi chassis GSN's seem to assign source port ranges to
>> chassis, but that has nothing todo with DDOS protection.
>
> This is exactly what other UDP tunnel implementations did before
> flow separation was prevelant.
>
> I don't see the point of any of this discussion discouraging the
> enablement of proper flow separation.

Hi Dave,

So where do we  go from here? should I resubmit the patch?

Or.
