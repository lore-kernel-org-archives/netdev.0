From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 14:28:20 +0100
Message-ID: <20140321132820.GM22728@two.firstfloor.org>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <87a9cknwk4.fsf@tassilo.jf.intel.com>
 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 21, 2014 at 05:50:50AM -0700, Eric Dumazet wrote:
> On Thu, 2014-03-20 at 18:56 -0700, Andi Kleen wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> writes:
> > >
> > > I saw csum_partial() consuming 1% of cpu cycles in a GRO workload, that
> > > is insane...
> > 
> > 
> > Couldn't it just be the cache miss?
> 
> Or the fact that we mix 16 bit stores and 32bit loads ?

It should cause a small stall from not doing load-store
forwarding, but 1% of a serious workload would be surprising.

Are you sure it's not some skid effect?

-Andi
