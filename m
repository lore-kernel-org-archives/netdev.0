From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 13:11:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD78C0D.4030609@us.ibm.com>
References: <Pine.LNX.4.44.0312101020480.21684-100000@w-kevinr.svc.beaverton.ibm.com>	<20031210203433.3747b7fd.ak@suse.de>	<3FD7826F.1050308@us.ibm.com> <20031210215527.239fb33f.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ruddk@us.ibm.com, netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031210215527.239fb33f.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> Only the router would need to change (and rewrite ICMP messages, which is a 
> bit nasty, but then compatibility is not always fun) 

True, but I get a sinking feeling when I hear we have to change
router/icmp code. The word "only" seems inappropriate ;).

> -Andi
> 
> P.S.: I am not opposed to fixing linux for this, just I have my doubts
> that fixing all end hosts is a practical solution for the problem.

The reason it seems simpler to me, at least, and I don't
speak for Kevin or the person at Intel who first reported
the problem, is that I see only a few people (well, only
Intel :)) running into the problem. So if there were a
patch available or the fix were in some release, only
the few end hosts who actually needed it would need to
upgrade. Otherwise, rollout would be evolutionary.

But also open to other approaches...

thanks,
Nivedita
