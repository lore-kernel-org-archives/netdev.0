From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: bk16 changes to cbq
Date: Tue, 6 Jul 2004 00:27:27 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705202727.GA21226@ms2.inr.ac.ru>
References: <1088861810.1039.298.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1088861810.1039.298.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> What i remember is this (4-5 years back) used to cure a bug - cant
> remember the details unfortunately, but Alexey may remember.

Actually, I do not. It looks like an optimization: if the device is
throttled we just do not need to add timer, qdisc will be woken up
by unthrottle. I do not see any race condition here, but also I do not
see why this check could be important.

> At the expense of repeating a discussion that may have already happened,

To be honest, I wish to be reminded. If this check cured something,
it would be interesting to know what was this.

Alexey
