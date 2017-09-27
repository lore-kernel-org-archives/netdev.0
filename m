From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 0/3] support changing steering policies in tuntap
Date: Wed, 27 Sep 2017 19:25:37 -0400
Message-ID: <CAF=yD-J8hERZdwq8FJ2rtnCnZ2b7s=CAVLtPk4CS7e=RQH3sLQ@mail.gmail.com>
References: <1506500637-13881-1-git-send-email-jasowang@redhat.com> <20170927230042-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jason Wang <jasowang@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927230042-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> In the future, both simple and sophisticated policy like RSS or other guest
>> driven steering policies could be done on top.
>
> IMHO there should be a more practical example before adding all this
> indirection. And it would be nice to understand why this queue selection
> needs to be tun specific.

I was thinking the same and this reminds me of the various strategies
implemented in packet fanout. tun_cpu_select_queue is analogous to
fanout_demux_cpu though it is tun-specific in that it requires tun->numqueues.

Fanout accrued various strategies until it gained an eBPF variant. Just
supporting BPF is probably sufficient here, too.
