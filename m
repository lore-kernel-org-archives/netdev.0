From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: switchdev automated testing
Date: Wed, 27 Jan 2016 16:57:56 +0100
Message-ID: <20160127155756.GC2222@nanopsycho.orion>
References: <20160127144657.GB2222@nanopsycho.orion>
 <20160127155114.GB20194@lunn.ch>
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
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33811 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127AbcA0P57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 10:57:59 -0500
Received: by mail-wm0-f65.google.com with SMTP id p63so4152509wmp.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 07:57:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160127155114.GB20194@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 27, 2016 at 04:51:14PM CET, andrew@lunn.ch wrote:
>On Wed, Jan 27, 2016 at 03:46:57PM +0100, Jiri Pirko wrote:
>> Hi All.
>> 
>> Just want to send a small note here about what we use for mlxsw driver
>> automated testing. It can be handy for other people using switchdev
>> infra, namely DSA guys.
>
>Hi Jiri
>
>I have a few hacked together python scripts combined with the Ostinato
>drone, integrated into a Jenkins CI system, for testing DSA.
>
>Taking a quick look at the XML files, it looks like we took different
>approaches. I have a host with 8 Ethernet interfaces connected to the
>switch. You appear to have many more machines, with one or two
>interfaces connected to the switch per machine. This is going to make
>it difficult for me to run your tests using my setup.

You can run 2 lnst-slave instances on a single host, each using 4 NICs.
Then you can run our tests as well. Or you can setup 2 VMs and put NICs
in them using pci passthrough.


>
>I only took a quick look at the tests, but it also does not seem like
>the linux machine in the switch itself is involved in the
>tests. e.g. l2-000-minimal.py, you put IP addresses on the two
>machines connected to the switch, but what about putting an address on
>the linux bridge interface and make sure you can ping that as well?
>This is important for DSA, since the switch is often embedded in a
>WiFi access point and a lot of traffic is coming from the wifi device
>attached to the linux host.

This usecase we do not test now. But it is very easy to add another
recipe for this.


>
>> It's just a start. We'd like to make them more complete, possibly with
>> your help.
>
>If i can make them work with my testbed setup, and i can get test
>results in a form Jenkins understands, i would be interested in using
>them.

AFAIK, we run LNST from Jenkins as well. That should not be a problem.


>
>Are you going to be in the netdev 1.1 switchdev BoF? Maybe we can
>discuss testing there?

I will be there. Sure, lets discuss it there.
