From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 12:58:34 +0200
Message-ID: <46C57F5A.2050205@s5r6.in-berlin.de>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com> <46C512EB.7020603@yahoo.com.au> <46C54D74.60101@s5r6.in-berlin.de> <46C556F1.8000407@yahoo.com.au> <46C57D07.80604@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:45124 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756066AbXHQK6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 06:58:36 -0400
In-Reply-To: <46C57D07.80604@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wrote:
> Nick Piggin wrote:
>> You might find that these places that appear to need barriers are
>> buggy for other reasons anyway. Can you point to some in-tree code
>> we can have a look at?
> 
> I could, or could not, if I were through with auditing the code.  I
> remembered one case and posted it (nodemgr_host_thread) which was safe
> because msleep_interruptible provided the necessary barrier there, and
> this implicit barrier is not in danger to be removed by future patches.

PS, just in case anybody holds his breath for more example code from me,
I don't plan to continue with an actual audit of the drivers I maintain.
It's an important issue, but my current time budget will restrict me to
look at it ad hoc, per case.  (Open bugs have higher priority than
potential bugs.)
-- 
Stefan Richter
-=====-=-=== =--- =---=
http://arcgraph.de/sr/
