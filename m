From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Tue, 6 Jul 2004 18:51:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706185146.4894e9d9.davem@redhat.com>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	<20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	<1088824432.1043.271.camel@jzny.localdomain>
	<20040706090906.4ff6fb73@dell_ss3.pdx.osdl.net>
	<1089164179.1039.26.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, util@deuroconsult.ro, netdev@oss.sgi.com,
        lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089164179.1039.26.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 06 Jul 2004 21:36:20 -0400
jamal <hadi@cyberus.ca> wrote:

> Not sure what the netfilter limit target is - i suspect its something
> that limits based on a group of flows. You can still do that with a
> fwamrk at the qdisc level. Reordering needs a queue. Even the example i
> gave uses a queue that resides on the dummy device.

It's a netfilter iptables module that essentially uses sch_tbf.c's
simple token bucket filter algorithm.

See net/ipv4/netfilter/ipt_limit.c for details.
