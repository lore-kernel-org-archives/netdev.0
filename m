From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] tcp: export do_tcp_sendpages and
 tcp_rate_check_app_limited functions
Date: Thu, 25 May 2017 13:26:53 -0400 (EDT)
Message-ID: <20170525.132653.192869313240485609.davem@davemloft.net>
References: <cover.1495642647.git.davejwatson@fb.com>
        <20170524162657.GA24165@davejwatson-mba.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilyal@mellanox.com, aviadye@mellanox.com, borisp@mellanox.com,
        liranl@mellanox.com, matanb@mellanox.com, netdev@vger.kernel.org,
        tom@herbertland.com, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org, hannes@stressinduktion.org,
        alexei.starovoitov@gmail.com, nmav@gnults.org,
        fridolin.pokorny@gmail.com
To: davejwatson@fb.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170524162657.GA24165@davejwatson-mba.local>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Watson <davejwatson@fb.com>
Date: Wed, 24 May 2017 09:26:57 -0700

> Export do_tcp_sendpages and tcp_rate_check_app_limited, since tls will need to
> sendpages while the socket is already locked.
> 
> tcp_sendpage is exported, but requires the socket lock to not be held already.
> 
> Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
> Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
> Signed-off-by: Boris Pismenny <borisp@mellanox.com>
> Signed-off-by: Dave Watson <davejwatson@fb.com>
 ...
> +EXPORT_SYMBOL(do_tcp_sendpages);
 ...
> +EXPORT_SYMBOL(tcp_rate_check_app_limited);

These need to both be EXPORT_SYMBOL_GPL().
