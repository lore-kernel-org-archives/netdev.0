From: David Brownell <david-b@pacbell.net>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Mon, 08 Apr 2002 10:48:51 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <035c01c1df3b$17243d40$6800000a@brownell.org>
References: <Pine.GSO.4.30.0204071623470.12041-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>, Stefan Rompf <srompf@isg.de>
List-Id: netdev.vger.kernel.org

> > The only useful state transitions are to/from IFOP_DOWN_NOCARRIER
> > in my opinion. What do you think?
> 
> I meant this view from a "listener" perspective; example from an
> SNMP NMS perspective or even a dynamic route daemon, this is the only
> really interesting state transition. So IMO, it only makes sense to send
> netlink messages for these.

But ... how about "carrier on"?  What else would be able to trigger
software to bring the interface up (so it could be routed or bridged)
if there were no notification for "carrier on"?  Not expecting some
administrator to be initating it (or eyeballing some status display);
one can ignore alerts, but one can't create them from nothing.

This is where my "asymmetry in design" alert triggers.  It's usually
been a good early warning system for trouble ... :)

- Dave
