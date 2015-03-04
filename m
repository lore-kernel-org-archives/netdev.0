From: Nicolae Rosia <nicolae.rosia@gmail.com>
Subject: Re: IPSec hmac(sha256) truncation bits length
Date: Wed, 4 Mar 2015 20:28:26 +0200
Message-ID: <CAH=tA9GQ643vpmk=wJUC1fmpD6A87SU-onhweMp8aYrTu+qsTA@mail.gmail.com>
References: <CAH=tA9Fnd6+gHsvjCv8oXqRVGLtdV9jr-KP1hxUGFg5orC5Qcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@intercode.com.au>, netdev@vger.kernel.org
To: "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAH=tA9Fnd6+gHsvjCv8oXqRVGLtdV9jr-KP1hxUGFg5orC5Qcw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ CC net, James Morris

On Wed, Mar 4, 2015 at 7:13 PM, Nicolae Rosia <nicolae.rosia@gmail.com> wrote:
> Hello,
>
> I'm trying to understand why icv_truncbits is set to 96 for
> hmac(sha256) in xfrm_algo.c because
> RFC4868 [1] says that the truncation length for HMAC-SHA256 should be 128.
> Am I looking in the wrong place?
>
> [1] https://tools.ietf.org/html/rfc4868#section-2.6
>
> Best regards,
> Nicolae Rosia
