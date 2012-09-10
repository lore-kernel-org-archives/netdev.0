From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [tcpdump-workers] Modular arithmetic
Date: Mon, 10 Sep 2012 09:41:02 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
References: <20120905213941.03c85968@arrowsmith> <C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu> <20120906073615.693d14e0@arrowsmith> <46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu> <20120907074910.2df46817@arrowsmith> <20120908030311.GM17289@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jay Schulist" <jschlst@samba.org>, <netdev@vger.kernel.org>
To: "Andi Kleen" <ak@linux.intel.com>,
	"George Bakos" <gbakos@alpinista.org>,
	<tcpdump-workers@lists.tcpdump.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51935 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753136Ab2IJIrz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 04:47:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24358-07 for <netdev@vger.kernel.org>;
 Mon, 10 Sep 2012 09:47:51 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120908030311.GM17289@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, Sep 07, 2012 at 07:49:10AM +0000, George Bakos wrote:
> > Gents,
> > Any fundamental reason why the following (, etc.) shouldn't be
> > included in net/core/filter.c?
> >
> >                 case BPF_S_ALU_MOD_X:
> >                         if (X == 0)
> >                                 return 0;
> >                         A %= X;
> >                         continue;
> 
> Copying netdev.
> 
> In principle no reason against it, but you may need to update
> the various BPF JITs too that Linux now has too.

What about the other OS - eg all the BSDs?
I had a vague idea that BPF was supposed to be reasonable portable.

	David    (dsl@netbsd.org)
