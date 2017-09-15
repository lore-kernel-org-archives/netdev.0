From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/packet: fix race condition between fanout_add and __unregister_prot_hook
Date: Fri, 15 Sep 2017 11:09:36 -0700
Message-ID: <CAM_iQpWVWoMesapdCQU=P=RF-49wcYGS+Xc7HWgjK8FFbn+rQw@mail.gmail.com>
References: <20170914140722.44292-1-nixiaoming@huawei.com> <CAF=yD-Jt5boxgQne4s1Fzy0y=Lq7RO4fjF6BfOCoh1bgaSECHQ@mail.gmail.com>
 <CAM_iQpWAeB+8bm9u+eHS3k_h5PSbnztXBvzTC=f0-tohdiSgzQ@mail.gmail.com> <CAF=yD-LZMjB5u0JRX36fYgV1HR6WqyJOGKopk5CLR=0rFBEV7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: nixiaoming <nixiaoming@huawei.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, waltje@uwalt.nl.mugnet.org,
        gw4pts@gw4pts.ampr.org, Andrey Konovalov <andreyknvl@google.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Philip Pettersson <philip.pettersson@gmail.com>,
        Alexander Potapenko <glider@google.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, dede.wu@huawei.com
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF=yD-LZMjB5u0JRX36fYgV1HR6WqyJOGKopk5CLR=0rFBEV7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 15, 2017 at 10:46 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>
> In case of failure we also need to unlink and free match. I
> sent the following:
>
> http://patchwork.ozlabs.org/patch/813945/

Ah, will take a look.
