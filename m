From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Sun, 29 Jun 2003 09:26:55 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306290924310.28882-100000@netcore.fi>
References: <3EFDF4DA.80201@hipac.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
In-Reply-To: <3EFDF4DA.80201@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Sat, 28 Jun 2003, Michael Bellion and Thomas Heinz wrote:
> You wrote:
> > Looks interesting.  Is there experience about this in bridging firewall 
> > scenarios? (With or without external patchset's like 
> > http://ebtables.sourceforge.net/)
> 
> Sorry for this answer being so late but we wanted to check whether
> nf-hipac works with the ebtables patch first in order to give you
> a definite answer. We tried on a sparc64 which was a bad decision
> because the ebtables patch does not work on sparc64 systems.
> We are going to test the stuff tomorrow on an i386 and tell you
> the results afterwards.
> 
> In principle, nf-hipac should work properly whith the bridge patch.
> We expect it to work just like iptables apart from the fact that
> you cannot match on bridge ports. The iptables' in/out interface
> match in 2.4 works the way that it matches if either in/out dev
> _or_ in/out physdev. The nf-hipac in/out interface match matches
> solely on in/out dev.

Thanks for this information.
 
> > Further, you mention the performance reasons for this approach.  I would 
> > be very interested to see some figures.
> 
> We have done some performance tests with an older release of nf-hipac.
> The results are available on http://www.hipac.org/
> 
> Apart from that Roberto Nibali did some preliminary testing on nf-hipac.
> You can find his posting to linux-kernel here: 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=103358029605079&w=2
> 
> Since there are currently no performance tests available for the
> new release we want to encourage people interested in firewall
> performance evaluation to include nf-hipac in their tests.

Yes, I had missed this when I quickly looked at the web page using lynx. 
Thanks.

One obvious thing that's missing in your performance and Roberto's figures 
is what *exactly* are the non-matching rules.  Ie. do they only match IP 
address, a TCP port, or what? (TCP port matching is about a degree of 
complexity more expensive with iptables, I recall.)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
