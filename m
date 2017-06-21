From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 04/13] sock: add SOCK_ZEROCOPY sockopt
Date: Wed, 21 Jun 2017 16:56:05 -0400
Message-ID: <CAF=yD-K6g5sJWNxuPM+-V=W2pOrmV8LNSrBv1HjYYFgJ7hmUeg@mail.gmail.com>
References: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com> <20170621203652.15306-5-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621203652.15306-5-willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2017 at 4:36 PM, Willem de Bruijn
<willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> From: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> The send call ignores unknown flags. Legacy applications may already
> unwittingly pass MSG_ZEROCOPY. Continue to ignore this flag unless a
> socket opts in to zerocopy.
>
> Introduce socket option SO_ZEROCOPY to enable MSG_ZEROCOPY processing.
> Processes can also query this socket option to detect kernel support
> for the feature. Older kernels will return ENOPROTOOPT.
>
> Signed-off-by: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

This was not rebased on top of the SO_PEERGROUPS patch. I will send a v3.
