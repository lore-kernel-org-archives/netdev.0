From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Fri, 1 Oct 2004 21:32:25 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0410011934160.26321-100000@dexter.psc.edu>
References: <Pine.NEB.4.33.0409301625560.13549-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.NEB.4.33.0409301625560.13549-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Thu, 30 Sep 2004, David S. Miller wrote:
>
> > Please help debug this John since I'm not seeing this here.

Here's what I've observed now: on one machine I have interface hangs after
a non-deterministic amount of time (usually within a few seconds) with TSO
on if I'm sending at a reasonably high rate with a 1500 byte MTU.  I get
no hangs with a 9000 byte mtu, or at a low rate (sending to a FastE host).
Interestingly, if the interface mtu is 9000, but I'm sending 1500 byte
packets, it does not seem to hang.  On a different machine (both P4's with
e1000's) I get no hangs.  The hangs happen even with 2.6.8.1 before the
recent TSO changes, so it's not a bug there.  I looked at some tcpdumps
and saw no strangeness in the last segments sent.

The good machine has an e7500 chipset and a 82544EI. The bad machine has a
ServerWorks chipset and a 82545GM.

Any suggestions on where to look for what's going wrong with the
interface?

Thanks,
  -John
