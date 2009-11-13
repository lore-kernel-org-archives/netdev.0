From: =?ISO-8859-15?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Fri, 13 Nov 2009 12:40:05 +0100
Message-ID: <4AFD4595.1070904@e-teleport.net>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net> <4AFD36C0.3090302@e-teleport.net> <4AFD3ED6.2040606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Shanahan <kmshanah@disenchant.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.e-teleport.net ([213.190.64.162]:59413 "EHLO
	smtp.e-teleport.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756159AbZKMLkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 06:40:00 -0500
In-Reply-To: <4AFD3ED6.2040606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
>
>>> There's some special-casing for VID 0 in velocity_init_cam_filter()=
=2E
>>> Does "ip link add link eth0 type vlan id 0" make any difference?
>>> If not, does "ip link set eth0 promisc on"?
>>>  =20
>>>      =20
>> When we patch the driver to support multiple vlan, we decide to use =
the
>> vlan 0 to desactivate the vlan filtering.
>>    =20
>
> Why? The usual behaviour is to receive both tagged and untagged
> frames.
>  =20
We decide this with fran=E7ois as an alternative to desactivate the NIC=
=20
vlan filtering instead of creating a modul parameter.
The vlan id 0 need to be created but not necessary activate.

In september 2008, we had a discution about exactly the same problem.
You speak about the possibility of an ALLVLAN device flag.

I think i proposed a patch to desactivate NIC vlan filtering when we ar=
e=20
in promisc mode but not used.
--=20
R=E9gis S=E9guier
