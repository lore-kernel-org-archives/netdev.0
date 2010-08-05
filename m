From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb.txt: Add igb documentation
Date: Wed, 4 Aug 2010 21:20:36 -0700
Message-ID: <AANLkTimTqMb+n9-v9PDeY2ByN3n2BD_eQfmxJ8ymyuyZ@mail.gmail.com>
References: <20100804001429.6571.95116.stgit@localhost.localdomain>
	<1280889274.13192.565.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:55653 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab0HEEUh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 00:20:37 -0400
In-Reply-To: <1280889274.13192.565.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

0On Tue, Aug 3, 2010 at 19:34, Ben Hutchings <bhutchings@solarflare.com=
> wrote:
> On Tue, 2010-08-03 at 17:15 -0700, Jeff Kirsher wrote:
> [...]
>> + =C2=A0Jumbo Frames
>> + =C2=A0------------
>> + =C2=A0Jumbo Frames support is enabled by changing the MTU to a val=
ue larger than
>> + =C2=A0the default of 1500. =C2=A0Use the ifconfig command to incre=
ase the MTU size.
>> + =C2=A0For example:
>> +
>> + =C2=A0 =C2=A0 =C2=A0 ifconfig eth<x> mtu 9000 up
>> +
>> + =C2=A0This setting is not saved across reboots.
>
> Not igb-specific.
>
> [...]
>> + =C2=A0Ethtool
>> + =C2=A0-------
>> + =C2=A0The driver utilizes the ethtool interface for driver configu=
ration and
>> + =C2=A0diagnostics, as well as displaying statistical information. =
=C2=A0Ethtool
>> + =C2=A0version 3.0 or later is required for this functionality, alt=
hough we
>> + =C2=A0strongly recommend downloading the latest version at:
>> +
>> + =C2=A0http://sourceforge.net/projects/gkernel.
>
> Not igb-specific, and seriously - 3.0?
>
>> + =C2=A0Enabling Wake on LAN* (WoL)
>> + =C2=A0---------------------------
>> + =C2=A0WoL is configured through the Ethtool* utility.
>
> Not igb-specific.
>
> [...]
>> + =C2=A0LRO
>> + =C2=A0---
>> + =C2=A0Large Receive Offload (LRO) is a technique for increasing in=
bound throughput
>> + =C2=A0of high-bandwidth network connections by reducing CPU overhe=
ad. It works by
>> + =C2=A0aggregating multiple incoming packets from a single stream i=
nto a larger
>> + =C2=A0buffer before they are passed higher up the networking stack=
, thus reducing
>> + =C2=A0the number of packets that have to be processed. LRO combine=
s multiple
>> + =C2=A0Ethernet frames into a single receive in the stack, thereby =
potentially
>> + =C2=A0decreasing CPU utilization for receives.
>
> Not igb-specific.
>
>> + =C2=A0NOTE: LRO requires 2.6.24 or later kernel version.
> [...]
>
> Which is irrelevant to an in-tree driver.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>

Thanks for the review Ben.

I am fine and agree with removing the reference to Ethtool version 3.0
and reference to LRO requiring 2.6.24 kernel.  Sorry we did not catch
the earlier...

As far as the 4 sections you noted as not being igb-specific, while
these sections are not specific to the driver, I see them as useful to
users trying to find more information on the driver and how to
configure it.  IMHO more documentation is more useful that too little,
as long as you are not adding bloat to the documentation which makes
it difficult to find what you are looking for.

If I am in minority here, I fine with removing the non-igb specific
sections as well.

--=20
Cheers,
Jeff
