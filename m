From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Tue, 09 Mar 2004 11:36:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404E1CC2.1010300@us.ibm.com>
References: <20040309180331.GC11604@wotan.suse.de>	<Pine.NEB.4.33.0403091307090.5230-100000@dexter.psc.edu>	<20040309102206.33c1720c@dell_ss3.pdx.osdl.net>	<404E1374.5050600@us.ibm.com> <20040309110323.1295cf92@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, Andi Kleen <ak@suse.de>,
        linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040309110323.1295cf92@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> I used ttcp and netperf, but the tests aren't as interesting as setting up the
> toplogies, like 1G Ethernet; Ethernet -> PPP -> Ethernet and Ethernet -> IRDA -> Ethernet
> and DSL connections through SSH.   Plus, LTP (and are local automated test machines)
> don't seem to be setup for multi-machine tests.

I agree the environments are more interesting
in this case - but not sure about just using ttcp
and netperf in this case. Single stream, I presume?
Both are blasting out data without disk I/O
occurring. I'm concerned about enterprise
server situations  seeing a hit due
to the memory/cacheline impact - i.e. catch
the environments where this is not going to be
of help. We might be able to get some other
performance benchmark run data (Specweb* ?).

I'm trying to solve two problems - testing of
the current mainline kernel for the new features
that have gone in and also helping the testing
guys with the automated testing of kernel.org
kernels for networking stuff (solving that multi-
machine problem if they haven't already)..

thanks,
Nivedita
