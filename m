From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 17:33:28 +0200
Message-ID: <a1d97437-ed79-7a2b-d865-cd4e72173057@gmail.com>
References: <20170313173432.GA31333@ast-mbp.thefacebook.com>
 <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
 <20170313183121.GA36306@ast-mbp.thefacebook.com>
 <CANn89iK1eyXH_6ViU0sj=yH+3+WVtVdXaAVBUkkcA=0dCvTkOA@mail.gmail.com>
 <20170313202300.GA52396@ast-mbp.thefacebook.com>
 <CANn89iK6+1KMuxv11TqvfNd2cWRPjWDNkFnO00uC15GMQfqs-g@mail.gmail.com>
 <20170313232137.GA77943@ast-mbp.thefacebook.com>
 <CANn89iL3ODh0xf=+P0gSYN-mGwACeeCO+OwtJzK5JEtOtMdPuw@mail.gmail.com>
 <20170313234050.GA82263@ast-mbp.thefacebook.com>
 <1489453331.28631.102.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170314045730.GA5211@ast-mbp.thefacebook.com>
 <CANn89i+y3ZSfb+3+W=0-5uGJ=gm0tr2sY033ZFmL2Xc4X6__eQ@mail.gmail.com>
 <1489501287.28631.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35309 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753344AbdCOPdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:33:32 -0400
Received: by mail-wr0-f195.google.com with SMTP id u108so2503338wrb.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 08:33:31 -0700 (PDT)
In-Reply-To: <1489501287.28631.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 14/03/2017 4:21 PM, Eric Dumazet wrote:
> On Tue, 2017-03-14 at 06:34 -0700, Eric Dumazet wrote:
>
>> So I will leave this to Mellanox for XDP tests and upstreaming this,
>> and will stop arguing with you, this is going nowhere.
>
> Tariq, I will send a v2, including these changes (plus the missing
> include of yesterday)
>
> One is to make sure high order allocations remove __GFP_DIRECT_RECLAIM
>
> The other is changing mlx4_en_recover_from_oom() to increase by
> one rx_alloc_order instead of plain reset to rx_pref_alloc_order
>
> Please test XDP and tell me if you find any issues ?
> Thanks !

I can do the XDP check tomorrow, and complete the patch review.
I will let you updated.

(I am replying this on V2 as well)

Regards,
Tariq
