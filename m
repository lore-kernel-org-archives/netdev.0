From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH] packet: Don't write vnet header beyond end of buffer
Date: Mon, 28 Aug 2017 14:39:55 -0400
Message-ID: <CAF=yD-Lps0R0LHBm+JjYn+d6BoaC-xmTohzD82MBCnACVyJNag@mail.gmail.com>
References: <20170828182941.10677-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828182941.10677-1-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 2:29 PM, Benjamin Poirier <bpoirier@suse.com> wrote:
> ... which may happen with certain values of tp_reserve and maclen.
>
> Fixes: 58d19b19cd99 ("packet: vnet_hdr support for tpacket_rcv")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> Cc: Willem de Bruijn <willemb@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks for fixing this, Benjamin.
