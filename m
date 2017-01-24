From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] powerpc: bpf: implement in-register swap for 64-bit
 endian operations
Date: Tue, 24 Jan 2017 16:13:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026CE48@AcuExch.aculab.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02635FB@AcuExch.aculab.com>
 <20170113175201.GD3470@naverao1-tp.localdomain>
 <1484492458.11927.17.camel@au1.ibm.com>
 <20170123192227.GE3820@naverao1-tp.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@fb.com" <ast@fb.com>,
        Madhavan Srinivasan <maddy@linux.vnet.ibm.com>,
        Michael Ellerman <mpe@ellerman.id.au>
To: "'Naveen N. Rao'" <naveen.n.rao@linux.vnet.ibm.com>,
        "Benjamin Herrenschmidt" <benh@au1.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:60847 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750755AbdAXQOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:14:01 -0500
In-Reply-To: <20170123192227.GE3820@naverao1-tp.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 'Naveen N. Rao'
> Sent: 23 January 2017 19:22
> On 2017/01/15 09:00AM, Benjamin Herrenschmidt wrote:
> > On Fri, 2017-01-13 at 23:22 +0530, 'Naveen N. Rao' wrote:
> > > > That rather depends on whether the processor has a store to load forwarder
> > > > that will satisfy the read from the store buffer.
> > > > I don't know about ppc, but at least some x86 will do that.
> > >
> > > Interesting - good to know that.
> > >
> > > However, I don't think powerpc does that and in-register swap is likely
> > > faster regardless. Note also that gcc prefers this form at higher
> > > optimization levels.
> >
> > Of course powerpc has a load-store forwarder these days, however, I
> > wouldn't be surprised if the in-register form was still faster on some
> > implementations, but this needs to be tested.
> 
> Thanks for clarifying! To test this, I wrote a simple (perhaps naive)
> test that just issues a whole lot of endian swaps and in _that_ test, it
> does look like the load-store forwarder is doing pretty well.
...
> This is all in a POWER8 vm. On POWER7, the in-register variant is around
> 4 times faster than the ldbrx variant.
...

I wonder which is faster on the little 1GHz embedded ppc we use here.

	David
