From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: r8169: panic on 2.6.11
Date: Mon, 7 Mar 2005 10:59:36 -0800
Message-ID: <20050307105936.12bca470@dxpl.pdx.osdl.net>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
	<20050304145317.772859da@dxpl.pdx.osdl.net>
	<20050304230214.GC1148@electric-eye.fr.zoreil.com>
	<200503041728.54026.jdmason@us.ibm.com>
	<20050304154903.7b7e0fb1@dxpl.pdx.osdl.net>
	<20050305003735.GE1148@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050305003735.GE1148@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Mar 2005 01:37:35 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > Added this and took out "too much work at interrupt message"
> 
> Ok (leaks but see below).
> 
> > And got this (before it died):
> > 
> > eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:106ad012
>                            ^^^^^^
> 3ff0 would be a ~16k packet. The high weight byte is
> missing: the descriptor would be strictly somewhere between
> the first descriptor and the last descriptor for the packet.
> 
> opts=80xxxx -> FIFO overflow (*bulb flashes*)
> 
> The code does not look pretty there.


Doesn't come up because it gets that bit set in the normal case.

eth0: Rx ERROR status=328440ff!!!
