From: Sujit K M <sjt.kar@gmail.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 13:47:39 +0530
Message-ID: <921ca19c0910100117xdb94fcbo43e9b8ffaf4db997@mail.gmail.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009210909.GA9836@auslistsprd01.us.dell.com>
	 <20091009194401.036da080@nehalam>
	 <20091010044056.GA5350@mock.linuxdev.us.dell.com>
	 <20091010052308.GA12458@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f187.google.com ([209.85.216.187]:37883 "EHLO
	mail-px0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbZJJIX2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 04:23:28 -0400
In-Reply-To: <20091010052308.GA12458@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg,


> No, the hardware changes the enumeration order, it places _no_
> guarantees on what order stuff will be found in. =A0So this is not th=
e
> kernel changing, just to be clear.
> Again, I have a machine here that likes to reorder PCI devices every =
4th
> or so boot times, and that's fine according to the PCI spec. =A0Yeah,=
 it's
> a crappy BIOS, but the manufacturer rightly pointed out that it is no=
t
> in violation of anything.
>

I think the open call should be implemented then. By the patch very lit=
tle
knowledge is being shared on type of network implementation it is tryin=
g to
do.Also it is messing with core datastructure and procedures. This seem=
s
to be simplified by changing implementing the other operations like pol=
l().

> That is why all distros name network devices based on the only
> deterministic thing they have today, the MAC address. =A0I still fail=
 to
> see why you do not like this solution, it is honestly the only way to
> properly name network devices in a sane manner.

This is feature that needs to be implemented. As per the rules followed=
=2E

>
> All distros also provide a way to easily rename the network devices, =
to
> place a specific name on a specific MAC address, so again, this shoul=
d
> all be solved already.
>
> No matter how badly your BIOS teams mess up the PCI enumeration order=
 :)

This is an problem, But I think this can be solved by implementing some=
 of the
routines in the network device.
