From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH] crypto_free_tfm callers do not need to check for NULL
Date: Tue, 30 Aug 2005 23:26:50 +0200
Message-ID: <9a87484905083014267caba221@mail.gmail.com>
References: <200508302245.55392.jesper.juhl@gmail.com>
	 <1125436415.3952.11.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@mail.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin Reed <breed@users.sourceforge.net>,
	Andy Adamson <andros@citi.umich.edu>, netdev@vger.kernel.org,
	lksctp developers <lksctp-developers@lists.sourceforge.net>,
	Bruce Fields <bfields@umich.edu>,
	Andy Adamson <andros@umich.edu>, linux-net@vger.kernel.org,
	linux-crypto@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932479AbVH3V0x@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1125436415.3952.11.camel@w-sridhar2.beaverton.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/30/05, Sridhar Samudrala <sri@us.ibm.com> wrote:
> On Tue, 2005-08-30 at 22:45 +0200, Jesper Juhl wrote:
> > Since the patch to add a NULL short-circuit to crypto_free_tfm() went in,
> > there's no longer any need for callers of that function to check for NULL.
> > This patch removes the redundant NULL checks and also a few similar checks
> > for NULL before calls to kfree() that I ran into while doing the
> > crypto_free_tfm bits.
> >
> > I've posted similar patches in the past, but was asked to first until the
> > short-circuit patch moved from -mm to mainline - and since it is now
> > firmly there in 2.6.13 I assume there's no problem there anymore.
> > I was also asked previously to make the patch against mainline and not -mm,
> > so this patch is against 2.6.13.
> >
> > Feedback, ACK, NACK, etc welcome.
> 
> sctp change looks fine.
> A similar check in sctp_endpoint_destroy() can also be removed.
> 
Thanks, I'll remember that and either update the patch or send a small
incremental one later.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
