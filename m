From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 12:30:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD7826F.1050308@us.ibm.com>
References: <Pine.LNX.4.44.0312101020480.21684-100000@w-kevinr.svc.beaverton.ibm.com> <20031210203433.3747b7fd.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kevin W. Rudd" <ruddk@us.ibm.com>, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031210203433.3747b7fd.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> I don't think the network users will be very happy if you require changing all
> end hosts this way. How about the following hack? For DF=1 packets
> the ipid field is useless. When you rewrite the TOS to DSCP save
> the old TOS in the ipid field.  When you see an ICMP fragment required
> message with the right DSCP on the router restore the old TOS from the ipid 
> field.

Wouldnt this require changes at the both ends, router and
host? How would we sync?

thanks,
Nivedita
