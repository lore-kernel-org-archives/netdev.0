From: "Jaswinder Singh Rajput" <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BUG - 2.4.37 fealnx.c NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 2 Jan 2009 21:18:35 +0530
Message-ID: <3f9a31f40901020748m242c46djf153fbab90eeca60@mail.gmail.com>
References: <3f9a31f40901020640m4a9a63caq9c96ba84ccd64d88@mail.gmail.com>
	 <20090102144813.GA13757@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wtarreau-Dj75qbTlC0E76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Willy Tarreau" <w@1wt.eu>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090102144813.GA13757-K+wRfnb2/UA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Willy,

On 1/2/09, Willy Tarreau <w@1wt.eu> wrote:
> On Fri, Jan 02, 2009 at 08:10:50PM +0530, Jaswinder Singh Rajput wrote:
>> Now I tested fealnx driver from 2.4.37 (2.4 git). I am still getting
>> "NETDEV WATCHDOG: eth0: transmit timed out". Please let me know how
>> can I fix this problem.
>
> Well, I don't have such an adapter, but most of the times I encountered
> a similar message with older 10/100 adapters, it was caused by a link
> status issue or duplex mismatch.
>
I think I am also getting same problem, what is the solution.

> Could you check with ethtool or mii-diag that the link status is correct
> and 100 Mbps/Full duplex (assuming you're connected to a switch) ?
>

Output of mii-diag -v :
eth0: 10 Mbit, half duplex, no link
  product info: vendor 00:00:00, model 0 rev 0
  basic mode:   10 Mbit, half duplex
  basic status: no link
  capabilities:
  advertising:

This is the output from very old machine Pentium MMX with Redhat 7.1

I also tested different RTL8139 adapters on different machines with
different kernels and different kind of switches and Hubs but I get
same error on all the machines. But my other Network devices are
working perfectly.

Thank you,
JSR
