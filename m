From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] Use RCU for fib_rules
Date: Wed, 31 Mar 2004 13:05:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331130541.4b1e8b0d@dell_ss3.pdx.osdl.net>
References: <20040331112839.02e8d4c2@dell_ss3.pdx.osdl.net>
	<406B2828.7070800@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Paul McKenney
 <Paul.McKenney@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <406B2828.7070800@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Mar 2004 12:20:56 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Stephen Hemminger wrote:
> 
> > The IP forwarding rules, uses rwlock when it could use RCU.
> > Don't know if this would help or hurt the recent discussions about
> > large rulesets and DOS attacks.
> > 
> > Also, it increases the size of fib_rule slightly.
> 
> Stephen,
> 
> Any benchmarks or perf tests that quantify the gain here?

No, don't have enough rules or load in this area to cause an impact.
But also, I don't have the test environment to really stress this
(ie 1000's of rules).
