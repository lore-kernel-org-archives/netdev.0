From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] Use RCU for fib_rules
Date: Wed, 31 Mar 2004 13:11:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331131107.151005a7.davem@redhat.com>
References: <20040331112839.02e8d4c2@dell_ss3.pdx.osdl.net>
	<406B2828.7070800@us.ibm.com>
	<20040331130541.4b1e8b0d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, Paul.McKenney@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040331130541.4b1e8b0d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Mar 2004 13:05:41 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> No, don't have enough rules or load in this area to cause an impact.
> But also, I don't have the test environment to really stress this
> (ie 1000's of rules).

You really don't need 1000's of rules.  Every time the routing cache
misses, it's going to dive into this code, so on SMP that would show up.

You could use stream.c (http://www.securiteam.com/unixfocus/5YP0I000DG.html)
as the DoS workload in order to thrash the routing cache and force the
rule codepath.
