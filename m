From: Nikos Mavrogiannopoulos <nmav@gnutls.org>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 16:49:46 +0200
Message-ID: <AANLkTikWRewCXdq3eeBMRQr3Ke7C2q42jnKqbKVwwpCH@mail.gmail.com>
References: <20100907084213.GA4610@gondor.apana.org.au>
	<20100907140646.GA31921@infradead.org>
	<20100907141112.GB6903@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20100907141112.GB6903@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 7, 2010 at 4:11 PM, Herbert Xu <herbert@gondor.hengli.com.a=
u> wrote:

>> > This is what I am proposing for the Crypto API user-interface.
>>
>> Can you explain why we would ever want a userspace interface to it?
>>
>> doing crypto in kernel for userspace consumers sis simply insane.
>> It's computational intensive code which has no business in kernel sp=
ace
>> unless absolutely required (e.g. for kernel consumers). =C2=A0In add=
ition
>> to that adding the context switch overhead and address space transit=
ions
>> is god awfull too.
>>
>> This all very much sounds like someone had far too much crack.
>
> FWIW I don't care about user-space using kernel software crypto at
> all. =C2=A0It's the security people that do.

Then I'd suggest to not enforce your design over to people who have
thought and have interests on that. The NCR api which you rejected
(for not supporting kernel keyring - which your design also doesn't!),
has specific security goals and protects against specific threats.
This design here has been proposed by you quite many times in the past
and neither you, nor anyone else bothered implementing it. Now we have
two working implementations that offer user-space access to crypto
operations, (the openbsd cryptodev port), and NCR, but you discard
them and insist on a different design. Maybe yours is better (you have
to argue about that)... Probably I'd use it if it was there, but it
isn't.

regards,
Nikos
