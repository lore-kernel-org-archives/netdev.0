From: Andi Kleen <ak@suse.de>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 21:55:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210215527.239fb33f.ak@suse.de>
References: <Pine.LNX.4.44.0312101020480.21684-100000@w-kevinr.svc.beaverton.ibm.com>
	<20031210203433.3747b7fd.ak@suse.de>
	<3FD7826F.1050308@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ruddk@us.ibm.com, netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3FD7826F.1050308@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 12:30:39 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:
 
> > I don't think the network users will be very happy if you require changing all
> > end hosts this way. How about the following hack? For DF=1 packets
> > the ipid field is useless. When you rewrite the TOS to DSCP save
> > the old TOS in the ipid field.  When you see an ICMP fragment required
> > message with the right DSCP on the router restore the old TOS from the ipid 
> > field.
> 
> Wouldnt this require changes at the both ends, router and
> host? How would we sync?

Only the router would need to change (and rewrite ICMP messages, which is a 
bit nasty, but then compatibility is not always fun) 

-Andi

P.S.: I am not opposed to fixing linux for this, just I have my doubts
that fixing all end hosts is a practical solution for the problem.
