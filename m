From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Tue, 25 Feb 2014 03:23:10 +0100
Message-ID: <20140225022310.GH6598@order.stressinduktion.org>
References: <1393266120.8041.19.camel@dcbw.local> <20140224.180426.411052665068255886.davem@davemloft.net> <1393286520.6823.123.camel@deadeye.wl.decadent.org.uk> <20140224.191238.921310808350170272.davem@davemloft.net> <1393293719.6823.148.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, dcbw@redhat.com,
	mcgrof@do-not-panic.com, zoltan.kiss@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1393293719.6823.148.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 25, 2014 at 02:01:59AM +0000, Ben Hutchings wrote:
> On Mon, 2014-02-24 at 19:12 -0500, David Miller wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Tue, 25 Feb 2014 00:02:00 +0000
> > 
> > > You can run an internal network, or access network, as v6-only with
> > > NAT64 and DNS64 at the border.  I believe some mobile networks are doing
> > > this; it was also done on the main FOSDEM wireless network this year.
> > 
> > This seems to be bloating up the networking headers of the internal
> > network, for what purpose?
> > 
> > For mobile that's doubly inadvisable.
> 
> I don't know what the reasoning is for the mobile network operators.
> They're forced to do NAT for v4 somewhere, and maybe v6-only makes the
> access network easier to manage.

Yes, it seems the way to go:
<http://www.dslreports.com/shownews/TMobile-Goes-IPv6-Only-on-Android-44-Devices-126506>

I can't comment on the 464xlat that much because I haven't looked at an
implementation yet, but it can very well be the case it still needs IPv4
on the outgoing interface, I don't know (from the spec pov it doesn't
look like that).

Greetings,

  Hannes
