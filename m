From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Tue, 9 Mar 2004 11:03:23 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040309110323.1295cf92@dell_ss3.pdx.osdl.net>
References: <20040309180331.GC11604@wotan.suse.de>
	<Pine.NEB.4.33.0403091307090.5230-100000@dexter.psc.edu>
	<20040309102206.33c1720c@dell_ss3.pdx.osdl.net>
	<404E1374.5050600@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, Andi Kleen <ak@suse.de>,
	linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <404E1374.5050600@us.ibm.com>
List-Id: netdev.vger.kernel.org

On Tue, 09 Mar 2004 10:56:52 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Stephen Hemminger wrote:
> 
> > Every case I tested has vegas faster than the default reno.  It is especially
> > noticeable over the DSL.  The current implementation is not ready to be turned
> > on by default though.
> 
> Stephen, just a question regarding your testing.
> (To save me some effort ;-)). What tests did you
> run, which testcases, and if it wasn't some standard
> benchmark, will you consider inclusion of those tests into
> the LTP or equivalent?

I used ttcp and netperf, but the tests aren't as interesting as setting up the
toplogies, like 1G Ethernet; Ethernet -> PPP -> Ethernet and Ethernet -> IRDA -> Ethernet
and DSL connections through SSH.   Plus, LTP (and are local automated test machines)
don't seem to be setup for multi-machine tests.

