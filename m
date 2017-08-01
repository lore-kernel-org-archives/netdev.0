From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] ipv6: set fc_protocol with 0 when rtm_protocol is RTPROT_REDIRECT
Date: Tue, 1 Aug 2017 14:50:49 +1200
Message-ID: <CADvbK_cxHL2XkpAnwo5jsNmHq4K1ou+5oakFkO=Ha8WVu=HBqQ@mail.gmail.com>
References: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
 <9fcbffcb-4a14-764c-7fe4-2108b8944c17@gmail.com> <CADvbK_ew8tD=sQQkZ03ijGafFQEzR0sf69DZ1_rNkX9E5mFpuw@mail.gmail.com>
 <11af493f-1128-cae6-d1a3-0d3d962da269@gmail.com> <CADvbK_dWwZU1EXf4ehAyV9cWOK-7b4hn=mGrytGTYACrCUUQ6g@mail.gmail.com>
 <b0edcf05-9ce4-94d4-3662-767e6ff86843@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        =?UTF-8?Q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33392 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbdHACuv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 22:50:51 -0400
Received: by mail-qk0-f175.google.com with SMTP id a77so2141501qkb.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 19:50:50 -0700 (PDT)
In-Reply-To: <b0edcf05-9ce4-94d4-3662-767e6ff86843@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 1, 2017 at 2:01 PM, David Ahern <dsahern@gmail.com> wrote:
> On 7/31/17 7:40 PM, Xin Long wrote:
>> To respect the old code more, setting RTPROT_RA only when
>> it's with the flag (ADDRCONF | DEFAULT | ROUTEINFO),
>> shouldn't it be:
>
> Look at rtm_fill_info:
>
>         if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
>                         rtm->rtm_protocol = RTPROT_RA;
>
>
> If either flag is set the protocol should be RTPROT_RA and looking at
> both places that seems correct to me.
>
ok, right
