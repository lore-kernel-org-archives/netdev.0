From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Sat, 28 Jun 2003 22:04:42 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3EFDF4DA.80201@hipac.org>
References: <Pine.LNX.4.44.0306270900260.3068-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
List-Id: netdev.vger.kernel.org

Hi Pekka

You wrote:
> Looks interesting.  Is there experience about this in bridging firewall 
> scenarios? (With or without external patchset's like 
> http://ebtables.sourceforge.net/)

Sorry for this answer being so late but we wanted to check whether
nf-hipac works with the ebtables patch first in order to give you
a definite answer. We tried on a sparc64 which was a bad decision
because the ebtables patch does not work on sparc64 systems.
We are going to test the stuff tomorrow on an i386 and tell you
the results afterwards.

In principle, nf-hipac should work properly whith the bridge patch.
We expect it to work just like iptables apart from the fact that
you cannot match on bridge ports. The iptables' in/out interface
match in 2.4 works the way that it matches if either in/out dev
_or_ in/out physdev. The nf-hipac in/out interface match matches
solely on in/out dev.

> Further, you mention the performance reasons for this approach.  I would 
> be very interested to see some figures.

We have done some performance tests with an older release of nf-hipac.
The results are available on http://www.hipac.org/

Apart from that Roberto Nibali did some preliminary testing on nf-hipac.
You can find his posting to linux-kernel here: 
http://marc.theaimsgroup.com/?l=linux-kernel&m=103358029605079&w=2

Since there are currently no performance tests available for the
new release we want to encourage people interested in firewall
performance evaluation to include nf-hipac in their tests.


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
