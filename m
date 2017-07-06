From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH v3 net-next 0/4] kernel TLS
Date: Thu, 6 Jul 2017 16:30:54 +0200
Message-ID: <CAFLxGvz=OfvZ4uOggkZjN7KKM11dzUp6Sd2O76SP5Nu_8Ty1gA@mail.gmail.com>
References: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        linux-crypto@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        nmav@gnutls.org, fridolin.pokorny@gmail.com
To: Dave Watson <davejwatson@fb.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

On Wed, Jun 14, 2017 at 8:36 PM, Dave Watson <davejwatson@fb.com> wrote:
>  Documentation/networking/tls.txt   | 135 +++++++
>  MAINTAINERS                        |  10 +
>  include/linux/socket.h             |   1 +
>  include/net/inet_connection_sock.h |   4 +
>  include/net/tcp.h                  |  27 ++
>  include/net/tls.h                  | 237 ++++++++++++
>  include/uapi/linux/tcp.h           |   1 +
>  include/uapi/linux/tls.h           |  79 ++++
>  net/Kconfig                        |   1 +
>  net/Makefile                       |   1 +
>  net/ipv4/Makefile                  |   2 +-
>  net/ipv4/sysctl_net_ipv4.c         |  25 ++
>  net/ipv4/tcp.c                     |  33 +-
>  net/ipv4/tcp_ipv4.c                |   2 +
>  net/ipv4/tcp_rate.c                |   1 +
>  net/ipv4/tcp_ulp.c                 | 134 +++++++
>  net/tls/Kconfig                    |  12 +
>  net/tls/Makefile                   |   7 +
>  net/tls/tls_main.c                 | 487 +++++++++++++++++++++++
>  net/tls/tls_sw.c                   | 772 +++++++++++++++++++++++++++++++++++++
>  20 files changed, 1968 insertions(+), 3 deletions(-)
>  create mode 100644 Documentation/networking/tls.txt
>  create mode 100644 include/net/tls.h
>  create mode 100644 include/uapi/linux/tls.h
>  create mode 100644 net/ipv4/tcp_ulp.c
>  create mode 100644 net/tls/Kconfig
>  create mode 100644 net/tls/Makefile
>  create mode 100644 net/tls/tls_main.c
>  create mode 100644 net/tls/tls_sw.c

Sorry for the late question. Do I miss something or is this IPv4 only?

-- 
Thanks,
//richard
