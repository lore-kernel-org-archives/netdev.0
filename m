From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Linux Routing Performance Update
Date: Sat, 29 Jan 2005 19:50:12 +0100
Message-ID: <87oef8m5nf.fsf@deneb.enyo.de>
References: <16887.39598.648724.421160@robur.slu.se>
	<41FA4498.6020202@aarnet.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Glen Turner <glen.turner@aarnet.edu.au>
In-Reply-To: <41FA4498.6020202@aarnet.edu.au> (Glen Turner's message of "Sat,
	29 Jan 2005 00:26:40 +1030")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Glen Turner:

>> Finally time for some more testing with a somewhat upgraded equipment.
>
> Thanks very much for the interesting results.

Indeed.

> I'm sure other network engineers have experienced software routers where
> the pps has dramatically slowed down upon reasonable ACLs and queuing
> (Cisco 7500, etc),

Cisco 7500 with proper configuration would do quite well in this test,
too, even with ACLs.  Only if you have more than a few thousand new
flows per second, things start to look rather bleak.  (Forwarding
decisions are performed once per flow on this platform.)

> so some results with netfilter and tc running would be appreciated,
> as would tests for any packet re-ordering in output flows.

I'd also like to see tests with random source/destination
combinations, just to keep things in perspective. 8-)
