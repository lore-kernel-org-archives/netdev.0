From: Julian Anastasov <ja@ssi.bg>
Subject: Re: routing bug report for 2.4
Date: Sat, 28 Jun 2003 23:38:11 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306282332380.1804-100000@u.domain.uli>
References: <3EFDE0BC.8040803@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EFDE0BC.8040803@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sat, 28 Jun 2003, Ben Greear wrote:

> What results do you get?  And did you set up policy based routing?

	I now see, the kernel sends "who-has local_IP" when you
use 'ping -I device local_IP'. If this is considered bad we can extend
the checks when fib_lookup fails:

- check for UP state (is it needed? return ENETDOWN?)
- check if target IP is local and select "lo" instead of oif

Regards

--
Julian Anastasov <ja@ssi.bg>
