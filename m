From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [iproute PATCH] man: tc-csum.8: Fix example
Date: Mon, 30 Jan 2017 13:12:48 +0100
Message-ID: <20170130121248.cchldekgvjcrxaxw@alphalink.fr>
References: <20170127111501.21439-1-phil@nwl.cc>
 <20170127204958.uo5ssloejdirohsj@alphalink.fr>
 <20170128111648.GX5197@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:50481 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753097AbdA3MMx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 07:12:53 -0500
Content-Disposition: inline
In-Reply-To: <20170128111648.GX5197@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 12:16:48PM +0100, Phil Sutter wrote:
> On Fri, Jan 27, 2017 at 09:49:58PM +0100, Guillaume Nault wrote:
> > On Fri, Jan 27, 2017 at 12:15:01PM +0100, Phil Sutter wrote:
> > > +# tc filter add dev eth0 prio 1 protocol ip parent ffff: \\
> > >  	u32 match ip src 192.168.1.100/32 flowid :1 \\
> > > -	action pedit munge ip dst set 0x12345678 pipe \\
> > > +	action pedit munge ip dst set 1.2.3.4 pipe \\
> > > 
> > Just nitpicking here, but IMHO examples like this should better use IP
> > addresses reserved for documentation (192.0.2.0/24, 198.51.100.0/24 or
> > 203.0.113.0/24).
> 
> Good point! This wasn't on my radar yet and I didn't know there were
> IPv4 ranges specifically for that purpose.
> 
The same exists for IPv6: 2001:db8::/32, reserved by RFC 3849. But I
guess you probably already figured it out.

> I guess the reasoning here is analogous to why one shouldn't use
> 'example.com' everywhere.
> 
Not sure about what you mean by "one shouldn't use 'example.com'
everywhere". Other domains may sometime be more appropriate (like
.invalid), but example.com is one of the domains reserved for
documentation by RFC 2606.

> Luckily, 1.2.3.0/24 seems to be reserved by APNIC for testing purposes.
> :)
> 
I'd expect that too many martians target these addresses. But AFAIK, in
theory, nothing prevents APNIC from allocating 1.2.3.0/24.
