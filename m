From: Niklas Edmundsson <nikke@ing.umu.se>
Subject: Re: martian packet checks breaks multi-homing
Date: Tue, 1 Jul 2003 11:22:50 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.56.0307011121130.5910@tekla.ing.umu.se>
References: <Pine.LNX.4.56.0307010921100.5910@tekla.ing.umu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.56.0307010921100.5910@tekla.ing.umu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Jul 2003, Niklas Edmundsson wrote:

>
> Hi!
>
> We are setting up a multi homed server (currently running Linux
> 2.4.18) connected to several physical networks (due to the fact that
> the server is a dhcp server too).

<snip>
> I haven't even been able to find a way to disable or circumvent the
> check other than edit the source (fib_validate_source() is rather hard
> to read by the way). It would be nice if there existed a runtime way
> to disable it.

Ignore me. Just after I sent this mail I found
/proc/sys/net/ipv4/conf/*/rp_filter which solves all my problems.
Sorry for the inconvenience.


/Nikke - spanks the paranoid debian startup scripts a bit.
-- 
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 Niklas Edmundsson, Admin @ {acc,hpc2n,ing}.umu.se    |   nikke@ing.umu.se
---------------------------------------------------------------------------
 There once was a man from Nantucket.You've been talking to Garibaldi!
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
