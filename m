From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 21:44:14 +0200
Message-ID: <cddb9608159b27a528fe87e94193dd0b@kernel.crashing.org>
References: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <18115.35524.56393.347841@cargo.ozlabs.ibm.com> <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com> <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <20070816005348.GA9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com> <20070816011414.GC9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in> <20070816020851.GA30809@gondor.apana.org.au> <Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com> <18115.49946.522011.832468@cargo.ozlabs.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59737 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbXHPTww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 15:52:52 -0400
In-Reply-To: <18115.49946.522011.832468@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'd go so far as to say that anywhere where you want a non-"volatile"
> atomic_read, either your code is buggy, or else an int would work just
> as well.

Even, the only way to implement a "non-volatile" atomic_read() is
essentially as a plain int (you can do some tricks so you cannot
assign to the result and stuff like that, but that's not the issue
here).

So if that would be the behaviour we wanted, just get rid of that
whole atomic_read() thing, so no one can misuse it anymore.


Segher

