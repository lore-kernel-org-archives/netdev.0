From: Nikos Mavrogiannopoulos <nmav@gnutls.org>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 16:57:04 +0200
Message-ID: <AANLkTinfQprsNC2ipocUKUWv894mbVtnDoxd5as9kCt-@mail.gmail.com>
References: <20100907084213.GA4610@gondor.apana.org.au>
	<20100907140646.GA31921@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20100907140646.GA31921@infradead.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 7, 2010 at 4:06 PM, Christoph Hellwig <hch@infradead.org> w=
rote:
>> This is what I am proposing for the Crypto API user-interface.
>
> Can you explain why we would ever want a userspace interface to it?
>
> doing crypto in kernel for userspace consumers sis simply insane.
> It's computational intensive code which has no business in kernel spa=
ce
> unless absolutely required (e.g. for kernel consumers). =C2=A0In addi=
tion
> to that adding the context switch overhead and address space transiti=
ons
> is god awfull too.
> This all very much sounds like someone had far too much crack.

Or that someone is not really aware of some cryptographic uses.
Embedded systems have crypto accelerators in hardware available
through kernel device drivers. In the systems I worked the
accelerators via a crypto device interface gave a 50x to 100x boost in
crypto operations and relieved the CPU from doing them.

regards,
Nikos
