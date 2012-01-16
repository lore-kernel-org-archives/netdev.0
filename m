From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Mon, 16 Jan 2012 12:20:47 +0200
Message-ID: <CACVxJT_+YZhK2oMU+iDKi_t_rMTarzrTh34Jqi1gPMicyf4=rw@mail.gmail.com>
References: <20120114204127.GA4100@p183.telecom.by>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, security@kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/16/12, David Laight <David.Laight@aculab.com> wrote:
> Doesn't this badly overflow W[] ..
>
>> +#define SHA512_0_15(i, a, b, c, d, e, f, g, h) \
>> +	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
> ...
>> +	for (i = 0; i < 16; i += 8) {
> ...
>> +		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
>> +	}

No, why should it?
i can be only 0 and 8.
