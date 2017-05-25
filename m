From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] kernel TLS
Date: Thu, 25 May 2017 13:29:32 -0400 (EDT)
Message-ID: <20170525.132932.2252528433754027808.davem@davemloft.net>
References: <20170524162633.GA24030@davejwatson-mba.local>
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
In-Reply-To: <20170524162633.GA24030@davejwatson-mba.local>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Watson <davejwatson@fb.com>
Date: Wed, 24 May 2017 09:26:33 -0700

> This series adds support for kernel TLS encryption over TCP sockets.
> A standard TCP socket is converted to a TLS socket using a setsockopt.
> Only symmetric crypto is done in the kernel, as well as TLS record
> framing.  The handshake remains in userspace, and the negotiated
> cipher keys/iv are provided to the TCP socket.
> 
> We implemented support for this API in OpenSSL 1.1.0, the code is
> available at https://github.com/Mellanox/tls-openssl/tree/master
> 
> It should work with any TLS library with similar modifications,
> a test tool using gnutls is here: https://github.com/Mellanox/tls-af_ktls_tool
> 
> Changes from RFC V2:
> 
> * Generic ULP (upper layer protocol) framework instead of TLS specific
>   setsockopts
> * Dropped Mellanox hardware patches, will come as separate series.
>   Framework will work for both.

The value in this is seeing how it can work transparently behind
an existing userspace library providing TLS services.

So the reference to the gnutls and openssl implementations probably
belongs in the Documentation patch #4 too.

Thanks.
