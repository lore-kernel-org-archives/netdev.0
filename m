From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: RE: Route cache performance under stress
Date: Tue, 10 Jun 2003 08:07:41 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610075702.I37165@shell.cyberus.ca>
References: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ralph+d@istop.com, CIT/Paul <xerox@foonet.net>,
	'Simon Kirby' <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
List-Id: netdev.vger.kernel.org



On Tue, 10 Jun 2003, Pekka Savola wrote:

> On Tue, 10 Jun 2003, Jamal Hadi wrote:
> > Typically, real world is less intense than the lab. Ex: noone sends
> > 100Mbps at 64 byte packet size.
>
> Some attackers do, and if your box dies because of that.. well, you don't
> like it and your managers certainly don't :-)
>

Assuming the attacker has a 100mbps link to you, yes ;->
I am not trying to say we should ignore it; infact all our tests
have been worst case scenarios.

> > Typical packet is around 500 bytes
> > average.
>
> Not sure that's really the case.  I have the impression the traffic is
> basically something like:
>  - close to 1500 bytes (data transfers)
>  - between 40-100 bytes (TCP acks, simple UDP requests, etc.)
>  - something in between
>

Its is typically trimodal (the ACKs, something in the 500 bytes and the
1500 byte end). The 500 average is derived from staring at cdf graphs:

slightly dated more thorough:
http://www.nlanr.net/NA/Learn/packetsizes.html

Frequent collections by sprint:
http://ipmon.sprint.com/packstat/packet.php?030407

so 500 bytes does sound reasonable.
Theres a lot of papers that have been written on this subject.

> > If linux can handle that forwarding capacity, it should easily
> > be doing close to Gige real world capacity.
>
> Yes, but not the worst case capacity you really have to plan for :-(
>

agreed.

> > Have you seen how the big boys advertise? when tuning specs they talk
> > about bits/sec. Juniper just announced a blade at supercom that can do
> > firewalling at 500Mbps.
>
> May be for some, but they *DO* give their pps figures also; many operators
> do, in fact, *explicitly* check the pps figures especially when there are
> some slower-path features in use (ACL's, IPv6, multicast, RPF, etc.):
> that's much more important than the optimal figures which are great for
> advertising material and press releases :-).
>

The announce in question i saw in some post supercom2003. I kept looking
for conditions that apply to get that 500mbops but couldnt find any.
A lot of people fall for the big brand name, so granted some people will
check, quiet a few dont have that expertise and will buy because iut reads
"juniper".

cheers,
jamal
