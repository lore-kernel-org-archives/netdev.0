From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: switchdev automated testing
Date: Wed, 27 Jan 2016 16:51:14 +0100
Message-ID: <20160127155114.GB20194@lunn.ch>
References: <20160127144657.GB2222@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
	linux@roeck-us.net, gospo@cumulusnetworks.com,
	roopa@cumulusnetworks.com, rami.rosen@intel.com,
	nikolay@cumulusnetworks.com, horms@verge.net.au,
	pjonnala@broadcom.com, olichtne@redhat.com, jtluka@redhat.com,
	jprochaz@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43898 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932213AbcA0PvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 10:51:23 -0500
Content-Disposition: inline
In-Reply-To: <20160127144657.GB2222@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 03:46:57PM +0100, Jiri Pirko wrote:
> Hi All.
> 
> Just want to send a small note here about what we use for mlxsw driver
> automated testing. It can be handy for other people using switchdev
> infra, namely DSA guys.

Hi Jiri

I have a few hacked together python scripts combined with the Ostinato
drone, integrated into a Jenkins CI system, for testing DSA.

Taking a quick look at the XML files, it looks like we took different
approaches. I have a host with 8 Ethernet interfaces connected to the
switch. You appear to have many more machines, with one or two
interfaces connected to the switch per machine. This is going to make
it difficult for me to run your tests using my setup.

I only took a quick look at the tests, but it also does not seem like
the linux machine in the switch itself is involved in the
tests. e.g. l2-000-minimal.py, you put IP addresses on the two
machines connected to the switch, but what about putting an address on
the linux bridge interface and make sure you can ping that as well?
This is important for DSA, since the switch is often embedded in a
WiFi access point and a lot of traffic is coming from the wifi device
attached to the linux host.

> It's just a start. We'd like to make them more complete, possibly with
> your help.

If i can make them work with my testbed setup, and i can get test
results in a form Jenkins understands, i would be interested in using
them.

Are you going to be in the netdev 1.1 switchdev BoF? Maybe we can
discuss testing there?

	Andrew
