From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: make sure to initialize sockc.tsflags before
 first use
Date: Wed, 22 Mar 2017 12:40:53 -0700 (PDT)
Message-ID: <20170322.124053.395077714485086280.davem@davemloft.net>
References: <20170321161427.103713-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        soheil@google.com, kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170321161427.103713-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Tue, 21 Mar 2017 17:14:27 +0100

> In the case udp_sk(sk)->pending is AF_INET6, udpv6_sendmsg() would
> jump to do_append_data, skipping the initialization of sockc.tsflags.
> Fix the problem by moving sockc.tsflags initialization earlier.
> 
> The bug was detected with KMSAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Applied and queued up for -stable, thank you.
