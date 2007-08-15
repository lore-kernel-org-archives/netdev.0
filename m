From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 22:52:07 +0800
Message-ID: <20070815145207.GA23106@gondor.apana.org.au>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <20070815081841.GA16551@osiris.boeblingen.de.ibm.com> <46C30540.2070603@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Chris Snook <csnook@redhat.com>, clameter@sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932873AbXHOOxh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 08:05:38PM +0530, Satyam Sharma wrote:
>
> > I don't know if this here is affected:
> 
> Yes, I think it is. You're clearly expecting the read to actually happen
> when you call get_hpsb_generation(). It's clearly not a busy-loop, so
> cpu_relax() sounds pointless / wrong solution for this case, so I'm now
> somewhat beginning to appreciate the motivation behind this series :-)

Nope, we're calling schedule which is a rather heavy-weight
barrier.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
