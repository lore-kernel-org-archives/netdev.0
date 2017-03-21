From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH] ipv6: make sure to initialize sockc.tsflags before first use
Date: Tue, 21 Mar 2017 12:25:58 -0400
Message-ID: <CACSApvbY0a6NFs+k1X5wMJC007z-NgYzgSdpuAncw6PHvNhu5g@mail.gmail.com>
References: <20170321161427.103713-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>, kcc@google.com,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170321161427.103713-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 21, 2017 at 12:14 PM, Alexander Potapenko <glider@google.com> wrote:
> In the case udp_sk(sk)->pending is AF_INET6, udpv6_sendmsg() would
> jump to do_append_data, skipping the initialization of sockc.tsflags.
> Fix the problem by moving sockc.tsflags initialization earlier.
>
> The bug was detected with KMSAN.

Nice catch and thanks for the fix! This is missing a "fixes"
attribution, added below.

> Signed-off-by: Alexander Potapenko <glider@google.com>

Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
