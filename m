From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] man: tc-csum.8: Fix example
Date: Sat, 28 Jan 2017 12:16:48 +0100
Message-ID: <20170128111648.GX5197@orbyte.nwl.cc>
References: <20170127111501.21439-1-phil@nwl.cc>
 <20170127204958.uo5ssloejdirohsj@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43369 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750829AbdA1LSM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Jan 2017 06:18:12 -0500
Content-Disposition: inline
In-Reply-To: <20170127204958.uo5ssloejdirohsj@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 09:49:58PM +0100, Guillaume Nault wrote:
> On Fri, Jan 27, 2017 at 12:15:01PM +0100, Phil Sutter wrote:
> > +# tc filter add dev eth0 prio 1 protocol ip parent ffff: \\
> >  	u32 match ip src 192.168.1.100/32 flowid :1 \\
> > -	action pedit munge ip dst set 0x12345678 pipe \\
> > +	action pedit munge ip dst set 1.2.3.4 pipe \\
> > 
> Just nitpicking here, but IMHO examples like this should better use IP
> addresses reserved for documentation (192.0.2.0/24, 198.51.100.0/24 or
> 203.0.113.0/24).

Good point! This wasn't on my radar yet and I didn't know there were
IPv4 ranges specifically for that purpose. I guess the reasoning here is
analogous to why one shouldn't use 'example.com' everywhere.

Luckily, 1.2.3.0/24 seems to be reserved by APNIC for testing purposes.
:)

I'll respin using another example address.

Thanks, Phil
