From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 17:50:07 -0700
Message-ID: <20070822005007.GG7574@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com> <46C997B1.1010800@redhat.com> <417ebba299a7ad3c4b7a31c4f860a814@kernel.crashing.org> <20070820224859.GA16162@flint.arm.linux.org.uk> <2bdb04581125f22122f1d230e991ea92@kernel.crashing.org> <20070821070555.GA32036@flint.arm.linux.org.uk> <18122.45437.807239.395869@cargo.ozlabs.ibm.com> <33412cad5894a9cbdc85482db5e9a0a0@kernel.crashing.org> <20070821161643.GA7574@linux.vnet.ibm.com> <28709.1187736676@turing-police.cc.vt.edu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>,
	Christoph Lameter <clameter@sgi.com>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, akpm@linux-foundation.org,
	rpjday@mindspring.com, Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	satyam@infradead.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:53549 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbXHVAuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 20:50:12 -0400
Content-Disposition: inline
In-Reply-To: <28709.1187736676@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 21, 2007 at 06:51:16PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 21 Aug 2007 09:16:43 PDT, "Paul E. McKenney" said:
> 
> > I agree that instant gratification is hard to come by when synching
> > up compiler and kernel versions.  Nonetheless, it should be possible
> > to create APIs that are are conditioned on the compiler version.
> 
> We've tried that, sort of.  See the mess surrounding the whole
> extern/static/inline/__whatever boondogle, which seems to have
> changed semantics in every single gcc release since 2.95 or so.
> 
> And recently mention was made that gcc4.4 will have *new* semantics
> in this area. Yee. Hah.

;-)

						Thanx, Paul
