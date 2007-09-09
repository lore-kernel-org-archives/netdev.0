From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sun, 9 Sep 2007 19:18:39 +0100
Message-ID: <20070909191839.1fa10e88@laptopd505.fenrus.org>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
	<46C59717.4020108@cyberone.com.au>
	<alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
	<200709091902.55388.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758980AbXIISVq@vger.kernel.org>
In-Reply-To: <200709091902.55388.vda.linux@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 9 Sep 2007 19:02:54 +0100
Denys Vlasenko <vda.linux@googlemail.com> wrote:

> Why is all this fixation on "volatile"? I don't think
> people want "volatile" keyword per se, they want atomic_read(&x) to
> _always_ compile into an memory-accessing instruction, not register
> access.

and ... why is that?
is there any valid, non-buggy code sequence that makes that a
reasonable requirement?
