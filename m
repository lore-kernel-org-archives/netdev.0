From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 13:43:40 +0000
Message-ID: <6278d2220811070543p51ca2139t13aba28e6dba5ff4@mail.gmail.com>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
	 <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
	 <20081105.151015.206163697.davem@davemloft.net>
	 <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
	 <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
	 <alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se>
	 <Pine.LNX.4.64.0811071039480.23629@wrl-59.cs.helsinki.fi>
	 <alpine.DEB.1.10.0811071230310.10993@uplift.swm.pp.se>
	 <Pine.LNX.4.64.0811071341430.23792@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Mikael Abrahamsson" <swmike@swm.pp.se>,
	"David Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org,
	"=?ISO
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811071341430.23792@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 7, 2008 at 12:22 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Fri, 7 Nov 2008, Mikael Abrahamsson wrote:
>> On Fri, 7 Nov 2008, Ilpo J=E4rvinen wrote:
>> > I think you partially miss the point here. In many cases not every
>> > single
>> > router has to _support_ ECN to get its benefits, not-supporting is=
 not
>> > the
>> > problem in itself (though it would be nice to get that "fixed" as =
well)
>> > but
>> > breaking ecn-enabled connections. I suppose you didn't check that
>> > aspect?
>> > I'd guess those mentioned devices will interoperate just fine sinc=
e one
>> > can
>> > mostly connect ok with ecn too besides rare exceptions rather than
>> > things
>> > being vice-versa.
>>
>> I don't understand. My point is that most of the ISP core equipment =
out
>> there
>> doesn't act on ECN rendering it mostly useless. The N in ECN renders
>> useless
>> because there is no device doing the *notification*. They'll just pa=
ss the
>> traffic without acting on it differently regardless if ECN is on or =
off.

I've been running with ECN enabled on all my client linux systems and
(personal) webservers for the past 6 or so years. When I've
encountered issues accessing particular hosts, I turn it and TCP
window scaling off, but invariably it is always another cause.

If most ECN-broken hardware is embedded consumer appliances (which are
generally short-lifespan and moving more and more to linux), then we
avoid hurting these users by enabling ECN per default when eg
CONFIG_IP_ADVANCED_ROUTER is set (to little direct benefit of course).
It's a start and a constructive idea; by doing this and documenting
it, we provide a wake-up call for vendors, laying the path for
enabling it for all types of host in a few years. Even enabling ECN
for -rc kernels will raise awareness.

Alternatively, an ECN-day could be publicised targeting the linux tech
community, where we can report failing networks/sites to a central
website to quantify actual potential negative impact.

But doing nothing is cyclic - when will the natural break suddenly occu=
r?
--=20
Daniel J Blueman
