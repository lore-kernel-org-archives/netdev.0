From: Jason Lunz <lunz@falooley.org>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Wed, 2 Apr 2003 04:19:23 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnb8kp6j.reg.lunz@orr.homenet>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D325@orsmsx402.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

scott.feldman@intel.com said:
> Robert, please post your -ro3 changes - I can't find them.

sorry, the -roX and -sfX notations are mine; i'm backporting everything
to 2.4.20 for testing and most of the patches have to be tweaked one way
or another, so I gave them all my own names to help keep them straight.
-ro1 and -ro2 come from Robert's posts here, and -ro3 is what you get
when you apply

ftp://robur.slu.se/pub/Linux/net-development/skb_recycling/e1000_pci_2.pat

on top of that.

> I'm pretty happy with this NAPI code for e1000.  Next step is to get
> some more generic QA testing with NAPI and then port back to 2.4.x.

For what it's worth, I've subjected various e1000 chipsets to just about
every kind of synthetic load all the way up to the maximum theoretical
full-duplex gigE framerate for hours without a hiccup. I'm using
backports from 2.5 with the TSO stuff stripped out. Judging from my
apache logs and the emails I get, quite a few others have been using
those patches on 2.4 too, but I've received no real complaints.

Jason
