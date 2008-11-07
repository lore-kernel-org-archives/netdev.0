From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 13:28:17 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811071039480.23629@wrl-59.cs.helsinki.fi>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
 <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
 <20081105.151015.206163697.davem@davemloft.net>
 <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
 <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
 <alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-137064504-1710806521-1226044487=:10993"
Cc: David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41875 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbYKGL2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 06:28:19 -0500
In-Reply-To: <alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se>
Content-ID: <Pine.LNX.4.64.0811071320450.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---137064504-1710806521-1226044487=:10993
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0811071039482.23629@wrl-59.cs.helsinki.fi>

On Fri, 7 Nov 2008, Mikael Abrahamsson wrote:

> On Fri, 7 Nov 2008, Ilpo Järvinen wrote:
> 
> > On Fri, 7 Nov 2008, Mikael Abrahamsson wrote:
> >
> > > On Wed, 5 Nov 2008, David Miller wrote:
> > >
> > > > This kind of thinking just perpetuates the problem forever.
> > >
> > > It's like the TCP option order "bug", where some devices would drop the
> > > packets because of buggy implementations, that was changed in Linux to
> > > work
> > > around others buggy code, and I see "ECN blackhole detection" as a similar
> > > measure.
> >
> > That is entirely bogus claim! The different ordering of options cost us
> > nothing, while disabling ECN certainly has an innumerable cost both in
> > performance and in nobody taking the initiative which makes the situation
> > worse for everybody.
> 
> I can't comment on "ECN blackhole detection" costing or costing none since I
> haven't been able to find the discussion between Alexey Kuznetsov and Sally
> Floyd that David Miller was referring to. Anything more to go on? A direct
> link to the thread would be great.

No idea about the mail. But anyway some cost comes from the fact that 
there is no desired to fix broken things then, nor even to start doing 
compliant equipment. Thus losing the potential benefits of ECN. It
has been around for years and we're still having this discussion about 
blackhole detection being necessary to keep operating, which is 
ridicilous.

And, would there be a need for reorder the TCP headers it would certainly 
get done with all breakage associated (not very likely that need will 
arise though because those parts of the header are well utilized already). 
It would basically be the same as with such things like window scaling, 
there's no window scaling blackhole detection in kernel besides one 
manually turning it off. Would there be detection why would those window 
scaling broken devices ever get fixed (and the corresponding end hosts 
would be doomed for 64k window forever)... Not to mention other similar 
examples.

> I have sent an email (which will hopefully initiate a discussion) to a
> mailinglist populated by a lot of the operational ISP community and asked
> around about ECN and views on that. I also checked around on core router
> platforms (Cisco 12000 and Cisco CRS-1, which definitely is two of the top
> three core router platforms deployed in the world) and it seems they do not
> support ECN as far as I can discern. This pretty much in the next 5 year
> timeframe ECN widespread support in the major core ISP networks out of the
> question, leaving ECN support on the slower links where it might be deployed
> faster. I doubt it though.

I think you partially miss the point here. In many cases not every single 
router has to _support_ ECN to get its benefits, not-supporting is not the 
problem in itself (though it would be nice to get that "fixed" as well) 
but breaking ecn-enabled connections. I suppose you didn't check that 
aspect? I'd guess those mentioned devices will interoperate just fine 
since one can mostly connect ok with ecn too besides rare exceptions 
rather than things being vice-versa.

The most crucial components are anyway the points of congestion, I don't 
know enough isp topologies but I suppose those core routers are not the 
ones where towards subscribers device traffic congests?

> Now, IPv6 for me is cruicial to the continuing life and prosperity of the
> Internet (NAT is bad). ECN is "nice to have".

Sure.

> I do see Linux (and Linux users) as leader(s) in deploying new technology,
> with ECN being one of them. Question is how much hurt we're going to take for
> it.

I doubt it any worse than with eg. timestamps.


-- 
 i.
---137064504-1710806521-1226044487=:10993--
