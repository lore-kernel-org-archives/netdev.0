From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 01:51:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927235117.GC15825@wotan.suse.de>
References: <20040923161141.4ea9be4c.davem@davemloft.net> <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu> <20040927160411.22b44f48.davem@davemloft.net> <20040927232554.GB15825@wotan.suse.de> <20040927163751.274f6071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, jheffner@psc.edu, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927163751.274f6071.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 04:37:51PM -0700, David S. Miller wrote:
> On Tue, 28 Sep 2004 01:25:55 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > Unfortunately not - with the patch applied I still get 27MB/s
> 
> And without TSO you get?  How exactly are you running netperf

~66MB/s

> and are you going through a switch?  I want to reproduce your

Yes, a buffalo gigabit switch.

> test case exactly here although using tg3 instead of e1000 :)

I'm running the test from a e1000 through the switch to a tg3
(tg3 with an older kernel).

I also tested it now from a tg3 machine to the other tg3 machine.
That's 48MB/s (with your patch). The tg3 machine is slower though
because the tg3 sits in a 33Mhz PCI slot, no CSA etc. 
>From the tg3 machine with your patch the numbers are the same
both with TSO on and off.

Looks like the e1000 is too fast...

-Andi
