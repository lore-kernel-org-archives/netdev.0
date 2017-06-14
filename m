From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/4] kernel TLS
Date: Wed, 14 Jun 2017 15:47:59 -0400 (EDT)
Message-ID: <20170614.154759.673143940024124611.davem@davemloft.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdFNTsC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:48:02 -0400
In-Reply-To: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

I really want to apply this, so everyone give it a good review :-)
