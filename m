From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/5] TCP BIC 1.1 support
Date: Mon, 11 Apr 2005 14:35:59 -0700
Message-ID: <20050411143559.32a0b764@dxpl.pdx.osdl.net>
References: <20050318162211.366ca490@dxpl.pdx.osdl.net>
	<423B9415.2010906@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <423B9415.2010906@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Mar 2005 02:53:09 +0000
Baruch Even <baruch@ev-en.org> wrote:

> Stephen Hemminger wrote:
> > This patch adds TCP BIC back in as a pluggable TCP congestion mechanism.
> > This version is closer to the TCP BIC 1.1 released for Web100.
> > The changes from 2.6.11 are:
> > 	* congestion window undo fix
> > 	* delayed ack compensation
> 
> This can cause overshooting if the other side doesn't do delayed acking, 
> did anyone consider the ABC (Appropriate Byte Counting) patch from 
> Yee-Ting Li? 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=110917262615630&w=2
> 
> FreeBSD has an option to disable delayed acking so it's not that hard to 
> work against a host with no delayed acks at all.

I tested with FreeBSD today and see no overshoot, but I do see the undershoot
(with Reno as well), because of the extra cwnd/2 that you already observed.
