From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Mon, 13 Feb 2017 16:47:26 -0800
Message-ID: <1487033246.8227.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170213195858.5215-1-edumazet@google.com>
         <20170213195858.5215-9-edumazet@google.com>
         <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
         <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
         <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
         <CANn89iJfLu8ai1SDGDt5aowAGibdxumDA89Y44f6SjTTt+sGBg@mail.gmail.com>
         <CAKgT0UdgnKzJ8PJFPfvJiOSZQ3E3Sw5nWjyrROuERv0=-dxmxQ@mail.gmail.com>
         <CANn89iLgUsPDL0wbuHk5RaehzJ+TRLQ=WkVBMTB65scrEjO3Ug@mail.gmail.com>
         <CAKgT0Uex--jLtBtJ+wp8wmkZuUfTu7ktYTvBF9623Ztm_NrGxw@mail.gmail.com>
         <CANn89iJ+kn4ycP2HV_um5JUfPWpX9KJ0KFtXyx3562c=kCBYyQ@mail.gmail.com>
         <CAKgT0Uf-JhOn+OOyjO8GH5SepA68j36eSY2m-buWJ5AH_82o2g@mail.gmail.com>
         <1487033175.8227.37.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:34633 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdBNAr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 19:47:28 -0500
Received: by mail-ot0-f194.google.com with SMTP id 73so14273204otj.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 16:47:28 -0800 (PST)
In-Reply-To: <1487033175.8227.37.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-13 at 16:46 -0800, Eric Dumazet wrote:

> Alex, be assured that I implemented the full thing, of course.
> 
> ( The pagecnt_bias field, .. refilled every 16K rounds )

Correction, USHRT_MAX is  ~64K, not 16K
