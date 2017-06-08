From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Wed, 7 Jun 2017 21:50:23 -0700
Message-ID: <CANn89iJi3OZ4LmC-seirR=qp=caQTOf0W-zvpe=DQCK7+qwg+w@mail.gmail.com>
References: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1496896364-27153-2-git-send-email-yanhaishuang@cmss.chinamobile.com> <20170608043847.uejvydlitzuik76j@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        "=David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:36213 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdFHEuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 00:50:25 -0400
Received: by mail-yw0-f178.google.com with SMTP id l75so9595283ywc.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 21:50:25 -0700 (PDT)
In-Reply-To: <20170608043847.uejvydlitzuik76j@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 7, 2017 at 9:38 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Jun 08, 2017 at 12:32:44PM +0800, Haishuang Yan wrote:
>> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
>> dst_release to free it in error code path.
>>
>> CC: Alexei Starovoitov <ast@fb.com>
>> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>
> I don't get it. Why did you send another version of the patch?
> What was wrong with previous approach that myself and Eric acked?
>

Answer lies in Pravin feedback on v2 of the patch on ipv4 side.
