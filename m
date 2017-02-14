From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Tue, 14 Feb 2017 13:56:47 -0800
Message-ID: <CANn89iK6Ecf2NNxKLy83WYK3WnuinGWc9J03UOpFROOWqE=Bog@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com> <CAKgT0UdRmpV_n1wstTHvqCgyRtze8z1rTJ5pKc_jdRttQCSySw@mail.gmail.com>
 <20170214194615.3feddd07@redhat.com> <CANn89iK4fnsjsK+GHYdT7_F0f++sa+t2LqrZWftjEryhF=hX+w@mail.gmail.com>
 <20170214210219.1ea87229@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        linux-mm <linux-mm@kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:38111 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbdBNV4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 16:56:49 -0500
Received: by mail-it0-f53.google.com with SMTP id c7so51120502itd.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 13:56:49 -0800 (PST)
In-Reply-To: <20170214210219.1ea87229@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This obviously does not work for the case I'm talking about
> (transmitting out another device with XDP).
>

XDP_TX does not handle this yet.

When XDP_TX was added, it was very clear that the transmit _had_ to be
done on the same port.

Since all this discussion happened in this thread ( mlx4: use order-0
pages for RX )
I was kind of assuming all the comments were relevant to current code or patch,
not future devs ;)
