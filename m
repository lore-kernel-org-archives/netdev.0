From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] padata: avoid race in reordering
Date: Sun, 26 Mar 2017 14:32:41 +0200
Message-ID: <CAHmME9qOxLHRY3sKSVWDDQ6o-vvUOsGLxbnLg97s0HvNjOyj3A@mail.gmail.com>
References: <CAHmME9oLWiprOyZXo7zvGm7xq+1Kchw9ybLS_TM-9xDyHF0mxQ@mail.gmail.com>
 <20170323112443.30843-1-Jason@zx2c4.com> <20170324094157.GE5279@secunet.com>
 <20170325.200151.245940842455044501.davem@davemloft.net> <20170326031145.GA19335@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170326031145.GA19335@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got a few other races in padata, I think, that I'm working on
fixing. If these pan out, I'll submit them exclusively to -crypto
instead of -netdev, to avoid this confusion next time. Of course, if
I'm able to fix these, then I'll probably be bald from pulling my hair
out during this insane debugging frenzy of the last few days...

Jason
