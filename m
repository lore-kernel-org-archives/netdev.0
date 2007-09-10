From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Mon, 10 Sep 2007 11:59:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709101154310.24491@schroedinger.engr.sgi.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
 <6370BBDF-0C79-41EB-BD2A-02AA0D216924@mac.com> <200709101438.36710.vda.linux@googlemail.com>
 <200709101516.03234.vda.linux@googlemail.com>
 <alpine.LFD.0.999.0709100807260.16478@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denys Vlasenko <vda.linux@googlemail.com>,
	Kyle Moffett <mrmacman_g4@mac.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760027AbXIJTAU@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0709100807260.16478@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Sep 2007, Linus Torvalds wrote:

> The fact is, "volatile" *only* makes things worse. It generates worse 
> code, and never fixes any real bugs. This is a *fact*.

Yes, lets just drop the volatiles now! We need a patch that gets rid of 
them.... Volunteers?
