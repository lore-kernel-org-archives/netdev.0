From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Wed, 10 Feb 2010 17:46:52 +0100
Message-ID: <4B72E2FC.1060003@trash.net>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net> <20091116005750.GR838@cubit> <loom.20100210T171704-457@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tiago Pierezan Camargo <tcamargo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54665 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab0BJQq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 11:46:58 -0500
In-Reply-To: <loom.20100210T171704-457@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tiago Pierezan Camargo wrote:
>> Kevin Shanahan <kmshanah <at> disenchant.net> writes:
>=20
> Hi
> Sorry for resurrecting an old thread, but I'm having the same problem=
 here.
>=20
>> On Fri, Nov 13, 2009 at 07:40:39AM +0100, Patrick McHardy wrote:
>>> Kevin Shanahan wrote:
>>>> Hi,
>>>>
>>>> I've had some problems with getting a fairly simple (I thought) VL=
AN
>>>> configuration working with the on board Via NICs on my Via M700
>>>> board. Looks like as soon as a tagged VLAN interface is added, the
>>>> underlying "raw" (untagged) interface stops responding.
>=20
> My setup is a bit different: I want to sniff all network activity, in=
cluding
> possible tagged traffic. No tagged interfaces are created.
>=20
>>>> A bit of searching found a few references to similar problems goin=
g
>>>> back a few years (2005, 2007). Sounded like there were some driver
>>>> issues, but it wasn't clear from the messages I found whether they
>>>> were believed to be fixed or not. I tried the same test using a
>>>> differnt NIC with the tg3 driver and there were no problems, so it
>>>> looks to me like it's still a via-velocity issue. Unfortunately I
>>>> don't have room to add NICs to this machine and need to use the on
>>>> board Via hardware.
>>> There's some special-casing for VID 0 in velocity_init_cam_filter()=
=2E
>>> Does "ip link add link eth0 type vlan id 0" make any difference?
>> Thanks Patrick, this command got the untagged interface working agai=
n
>> (eth1 in my case). I can use this as a work around.
>=20
> Unfortunately, Patrick's workaround doesn't work for me. To see any t=
agged
> packet I need to create a vlan that matches the packet vlan (same id)=
=2E
>=20
> R=E9gis' promiscous mode patch (http://lists.openwall.net/netdev/2008=
/10/08/106)
> does not work either. I tried to completely disable hw vlan filtering=
 without
> success. It seems my board uses a different register/offset to disabl=
e filtering.
>=20
> ...
>=20
> Any suggestions?

This should be fixed in the driver as discussed previously.
