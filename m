From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net: sched: fix NULL pointer dereference when action
 calls some targets
Date: Tue, 8 Aug 2017 12:33:22 -0700
Message-ID: <CAM_iQpXbtHDxVjZ=DoTiLXHLQy6q=JVBa66EqSOy95ZbFg-wkQ@mail.gmail.com>
References: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
 <CAM_iQpWcg0a46gJ6Qp3F1pqvvsaJYajmDC2uG_mi9Av_vkFo2w@mail.gmail.com> <CADvbK_fuuBrh+eOuhQU+SYs9uazH2TRP+KUmhxU=hNZ=EkOT=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:37264 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752414AbdHHTdn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 15:33:43 -0400
In-Reply-To: <CADvbK_fuuBrh+eOuhQU+SYs9uazH2TRP+KUmhxU=hNZ=EkOT=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 7, 2017 at 7:33 PM, Xin Long <lucien.xin@gmail.com> wrote:
> On Tue, Aug 8, 2017 at 9:15 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> This looks like a completely API burden?
> netfilter xt targets are not really compatible with netsched action.
> I've got to say, the patch is just a way to make checkentry return
> false and avoid panic. like [1] said

I don't doubt you fix a crash, I am thinking if we can
"fix" the API instead of fixing the caller.

I am not familiar with this API, so just my 2 cents...
