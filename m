From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next v3] netfilter: xt_hashlimit: Fix link error in
 32bit arch because of 64bit division
Date: Fri, 30 Sep 2016 10:53:20 +0900
Message-ID: <CANP3RGcdmHe3-w=20z1y3dbS0P3YdX7N2m+wF6g1xiAwrCjHng@mail.gmail.com>
References: <20160929173950.GA27689@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, johunt@akamai.com,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Linux NetDev <netdev@vger.kernel.org>,
        Vishwanath Pai <pai.vishwain@gmail.com>,
        Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
        zlpnobody@gmail.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        akpm@linux-foundation.org
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160929173950.GA27689@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +               return div64_u64((user * HZ * CREDITS_PER_JIFFY_v1),
> +                                XT_HASHLIMIT_SCALE);

spurious ()

> +               return div64_u64((user * HZ * CREDITS_PER_JIFFY),
> +                                XT_HASHLIMIT_SCALE_v2);

spurious ()

but:

Acked-by: Maciej =C5=BBenczykowski
