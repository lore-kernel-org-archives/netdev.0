From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] proportional share accept()
Date: Sun, 29 Feb 2004 22:05:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229220513.68eed11f.davem@redhat.com>
References: <Pine.LNX.4.44.0402251119060.3691-100000@dyn319495.beaverton.ibm.com>
	<Pine.GSO.4.51.0402261659350.24561@mamba.cs.Virginia.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kashyapv@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ronghua Zhang <rz5b@cs.virginia.edu>
In-Reply-To: <Pine.GSO.4.51.0402261659350.24561@mamba.cs.Virginia.EDU>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 Feb 2004 17:08:23 -0500 (EST)
Ronghua Zhang <rz5b@cs.virginia.edu> wrote:

> www.cs.virginia.edu/~rz5b/research/kernel-qos.htm

I looked at this, it's basically netfilter TCP port rewriting
which knows about per-socket quotas and limits.

You could write this as a 10 line netfilter module, with zero
modifications to any of the core net/ipv4 TCP code at all.
And that's how I'd like to see something like this done.

Otherwise it looks like a nice way of doing this.
