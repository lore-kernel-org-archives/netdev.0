From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re:
Date: Thu, 16 Aug 2007 03:38:43 +0200
Message-ID: <1ad8c70930530d4639a72e1c77d3904e@kernel.crashing.org>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <20070815081841.GA16551@osiris.boeblingen.de.ibm.com> <46C30540.2070603@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in> <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de> <20070815162722.GD9645@linux.vnet.ibm.com> <d4406222873856f472b9173a14a19aa2@kernel.crashing.org> <20070815185724.GH9645@linux.vnet.ibm.com> <alpine.LFD.0.999.0708160118330.16414@enigma.security.iitk.ac.in> <2d2eeab6276cab2e6cc5830d36a43b98@kernel.crashing.org> <alpine.LFD.0.999.0708160338520.22701@enigma.security.iitk.ac.in>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60490 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756473AbXHPBlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 21:41:10 -0400
In-Reply-To: <alpine.LFD.0.999.0708160338520.22701@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> "compilation unit" is a C standard term.  It typically boils down
>> to "single .c file".
>
> As you mentioned later, "single .c file with all the other files 
> (headers
> or other .c files) that it pulls in via #include" is actually 
> "translation
> unit", both in the C standard as well as gcc docs.

Yeah.  "single .c file after preprocessing".  Same thing :-)

> "Compilation unit"
> doesn't seem to be nearly as standard a term, though in most places it
> is indeed meant to be same as "translation unit", but with the new gcc
> inter-module-analysis stuff that you referred to above, I suspect one 
> may
> reasonably want to call a "compilation unit" as all that the compiler 
> sees
> at a given instant.

That would be a bit confusing, would it not?  They'd better find
some better name for that if they want to name it at all (remember,
none of these optimisations should have any effect on the semantics
of the program, you just get fewer .o files etc.).


Segher

