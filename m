From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Tue, 21 Sep 2004 17:11:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921211103.GC19575@kvack.org>
References: <1095714704.414f4790cd168@www.katalix.com> <20040920141704.16085067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>, netdev@oss.sgi.com,
        kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040920141704.16085067.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 02:17:04PM -0700, David S. Miller wrote:
> Ben didn't post any pointers to his work so I couldn't do the
> comparison myself.

It's still alpha and ugly, but... See src/mkifaces.cc for the microbench 
that shows the scaling issues with lots of interfaces.  I'd hoped to have 
time to test it on the weekend, but other stuff got in the way.  The quick 
guide to setup is:

	./configure --with-l2tp
	make
	insmod kernel/kern.o
	insmod drivers/l2tp/l2tp_k.o
	make -C src mkifaces
	src/mkifaces <num>

Although I'm not sure if this works on 2.6 in this build as most of my 
development was done on 2.4 over the summer.  Cheers,

		-ben
-- 
"Time is what keeps everything from happening all at once." -- John Wheeler
