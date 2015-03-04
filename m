From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: IPSec hmac(sha256) truncation bits length
Date: Wed, 4 Mar 2015 12:38:34 -0600
Message-ID: <20150304123834.c27417981d6ef63c0b310e11@freescale.com>
References: <CAH=tA9Fnd6+gHsvjCv8oXqRVGLtdV9jr-KP1hxUGFg5orC5Qcw@mail.gmail.com>
	<CAH=tA9GQ643vpmk=wJUC1fmpD6A87SU-onhweMp8aYrTu+qsTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	James Morris <jmorris@intercode.com.au>,
	<netdev@vger.kernel.org>
To: Nicolae Rosia <nicolae.rosia@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAH=tA9GQ643vpmk=wJUC1fmpD6A87SU-onhweMp8aYrTu+qsTA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Mar 2015 20:28:26 +0200
Nicolae Rosia <nicolae.rosia@gmail.com> wrote:

> On Wed, Mar 4, 2015 at 7:13 PM, Nicolae Rosia <nicolae.rosia@gmail.com> wrote:
> > I'm trying to understand why icv_truncbits is set to 96 for
> > hmac(sha256) in xfrm_algo.c because
> > RFC4868 [1] says that the truncation length for HMAC-SHA256 should be 128.

See http://comments.gmane.org/gmane.linux.kernel.cryptoapi/6767

Kim
