From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/4] kernel TLS
Date: Thu, 15 Jun 2017 12:13:11 -0400 (EDT)
Message-ID: <20170615.121311.1238287091540165656.davem@davemloft.net>
References: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilyal@mellanox.com, aviadye@mellanox.com, borisp@mellanox.com,
        liranl@mellanox.com, matanb@mellanox.com, netdev@vger.kernel.org,
        tom@herbertland.com, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org, hannes@stressinduktion.org,
        eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
        nmav@gnutls.org, fridolin.pokorny@gmail.com
To: davejwatson@fb.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Watson <davejwatson@fb.com>
Date: Wed, 14 Jun 2017 11:36:54 -0700

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
> RFC patch to openssl:
> https://mta.openssl.org/pipermail/openssl-dev/2017-June/009384.html
 ...

Series applied, thanks for all of this hard work!
