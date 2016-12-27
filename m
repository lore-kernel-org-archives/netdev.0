From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 4.10 1/6] crypto/sha256: Refactor the API so it can
 be used without shash
Date: Tue, 27 Dec 2016 17:58:53 +0800
Message-ID: <20161227095853.GA10588@gondor.apana.org.au>
References: <cover.1482545792.git.luto@kernel.org>
 <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
 <CAKv+Gu-UCqwchgbhg8VN4s=Yxk=PkjXG46NZo=8P4wAQtJ2TXw@mail.gmail.com>
 <CALCETrVbT_1=cdU1+a-+KbhoFqeT3XvbHjY0s_U7C5JVgiPx_Q@mail.gmail.com>
 <20161226075757.GA8916@gondor.apana.org.au>
 <CAKv+Gu-NMNCEs61f4k7JSf9iSJ1A_Gy1r=kZRGqtbDsEDz7--Q@mail.gmail.com>
 <CALCETrXFTQ2AXgbQzPnRcDRHK81=FS1R0zqfoTqGjUsqZy2PvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35875 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751256AbcL0J73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 04:59:29 -0500
Content-Disposition: inline
In-Reply-To: <CALCETrXFTQ2AXgbQzPnRcDRHK81=FS1R0zqfoTqGjUsqZy2PvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 26, 2016 at 10:08:48AM -0800, Andy Lutomirski wrote:
>
> According to Daniel, the networking folks want to let embedded systems
> include BPF without requiring the crypto core.

Last I checked the IPv4 stack depended on the crypto API so this
sounds bogus.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
