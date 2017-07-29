From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH V3 net-next] TLP: Don't reschedule PTO when there's one
 outstanding TLP retransmission
Date: Sat, 29 Jul 2017 10:04:17 -0400
Message-ID: <CADVnQykeDvPCQqvoox-oQkm5FdCvLQRvxZKC+TVmG7g-9CEoxw@mail.gmail.com>
References: <1501157337-10900-1-git-send-email-maowenan@huawei.com>
 <CADVnQy=Dw__BrTHwoUrn0Wxu8=Xb7NqZ9bAuEeM8SrNhzd_2SA@mail.gmail.com> <F95AC9340317A84688A5F0DF0246F3F2029326B6@DGGEMI512-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Chenweilong <chenweilong@huawei.com>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34452 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753827AbdG2OEs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 10:04:48 -0400
Received: by mail-oi0-f43.google.com with SMTP id x3so148902872oia.1
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 07:04:48 -0700 (PDT)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F2029326B6@DGGEMI512-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 9:39 PM, maowenan <maowenan@huawei.com> wrote:
> [Mao Wenan]ok, We have reproduced this issue with packetdrill yesterday,
> there is no the same issue when TLP send new data packet, RTO will be fired and
> retransmit packet.

That's great to hear that you were able to reproduce this with
packetdrill. Would you be able to share the packetdrill scripts that
reproduce your issues? I would like to make sure our proposed patch
addresses your scenarios as well.

thanks,
neal
