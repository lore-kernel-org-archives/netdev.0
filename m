From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC] Use RCU for fib_rules
Date: Wed, 31 Mar 2004 12:20:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406B2828.7070800@us.ibm.com>
References: <20040331112839.02e8d4c2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Paul McKenney <Paul.McKenney@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040331112839.02e8d4c2@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> The IP forwarding rules, uses rwlock when it could use RCU.
> Don't know if this would help or hurt the recent discussions about
> large rulesets and DOS attacks.
> 
> Also, it increases the size of fib_rule slightly.

Stephen,

Any benchmarks or perf tests that quantify the gain here?

thanks,
Nivedita
