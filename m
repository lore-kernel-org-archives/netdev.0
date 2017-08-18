From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 2/2] ifcfg: Quote left-hand side of [ ]
 expression
Date: Fri, 18 Aug 2017 16:38:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005AE2B@AcuExch.aculab.com>
References: <20170817170932.24900-1-phil@nwl.cc>
 <20170817170932.24900-3-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD005A809@AcuExch.aculab.com>
 <20170818112414.GJ10864@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:61105 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbdHRQiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:38:22 -0400
In-Reply-To: <20170818112414.GJ10864@orbyte.nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 18 August 2017 12:24
...
> > > -if [ `ip link ls $dev | grep -c MULTICAST` -ge 1 ]; then
> > > +if [ "`ip link ls $dev | grep -c MULTICAST`" -ge 1 ]; then
> >
> > You could drag all these scripts into the 1990's by using $(...)
> > instead of `...`.
> 
> That's a different kettle of fish IMO, using $() doesn't change the
> situation this addresses:
> 
> | $ [ $(echo foo bar) -eq 0 ] && echo ok
> | bash: [: too many arguments
> | $ [ "$(echo foo bar)" -eq 0 ] && echo ok
> | bash: [: foo bar: integer expression expected

I didn't say it would.
IFS=
set -o noglob
would though - not that I'd suggest it here.
protecting the 'eval' is somewhat harder.

	David
