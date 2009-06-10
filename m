From: Gil Beniamini <gil.beniamini@gmail.com>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Wed, 10 Jun 2009 18:29:34 +0300
Message-ID: <91ac27070906100829l683c69fbw93bb78813ee97ced@mail.gmail.com>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com>
	 <4A2E4A32.1060705@trash.net>
	 <91ac27070906090608me50af3bv23b150d8d0cd0080@mail.gmail.com>
	 <200906091430.32294.bcook@bpointsys.com>
	 <91ac27070906100724v25c2328x6b343315358c8e12@mail.gmail.com>
	 <4A2FC40E.4040106@trash.net>
	 <91ac27070906100748p1b2cb6bax56ecc230e556ae96@mail.gmail.com>
	 <20090610170108.7710c64b@tux.DEF.witbe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Brent Cook <bcook@bpointsys.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Rolland <rol@witbe.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:63946 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757808AbZFJP3e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 11:29:34 -0400
In-Reply-To: <20090610170108.7710c64b@tux.DEF.witbe.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul, Patrick,

THANKS!
using "vconfig set_name_type" DEV_PLUS_VID_NO_PAD" enable successful
"vconfig add eth1 <same-id as on eth0>". And now finally without
PROMISC the application receive BROADCASTs on this VLAN.

Many Thanks, Gil

2009/6/10 Paul Rolland <rol@witbe.net>:
> Hello,
>
> On Wed, 10 Jun 2009 17:48:40 +0300
> Gil Beniamini <gil.beniamini@gmail.com> wrote:
>
>> Dear Patrick,
>> Below is my try to add vlan-id 24 on eth1, followed by "ip -d link l=
ist":
>> root@StudentsHPA:/home/hpa# vconfig add eth1 24
>> ERROR: trying to add VLAN #24 to IF -:eth1:- =A0error: File exists
>
> Here is an output from my vconfig :
> bash-2.05$ /usr/local/witbe/sbin/vconfig
> Expecting argc to be 3-5, inclusive. =A0Was: 1
>
> Usage: add =A0 =A0 =A0 =A0 =A0 =A0 [interface-name] [vlan_id]
> =A0 =A0 =A0 rem =A0 =A0 =A0 =A0 =A0 =A0 [vlan-name]
> =A0 =A0 =A0 set_flag =A0 =A0 =A0 =A0[interface-name] [flag-num] =A0 =A0=
 =A0 [0 | 1]
> =A0 =A0 =A0 set_egress_map =A0[vlan-name] =A0 =A0 =A0[skb_priority] =A0=
 [vlan_qos]
> =A0 =A0 =A0 set_ingress_map [vlan-name] =A0 =A0 =A0[skb_priority] =A0=
 [vlan_qos]
> =A0 =A0 =A0 set_name_type =A0 [name-type]
>
> ...
> * bind-type: =A0PER_DEVICE =A0# Allows vlan 5 on eth0 and eth1 to be =
unique.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0PER_KERNEL =A0# Forces vlan 5 to be unique=
 across all devices.
>
> But the documentation is lacking information on how to set this :(
>
> Have a look at the source of vconfig should help...
>
> Paul
>
> --
> Paul Rolland =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0E-Mail : rol(at)witbe.net
> CTO - Witbe.net SA =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Tel. +33 (0)1 47 67 77 77
> Les Collines de l'Arche =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Fax. =
+33 (0)1 47 67 77 99
> F-92057 Paris La Defense =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RIPE =
: PR12-RIPE
>
> This is dedicated to all the ones who want to control Internet, its
> content or its usage :
>
> "I worry about my child and the Internet all the time, even though sh=
e's
> too young to have logged on yet. Here's what I worry about. I worry t=
hat 10
> or 15 years from now, she will come to me and say 'Daddy, where were =
you
> when they took freedom of the press away from the Internet?'"
> --Mike Godwin, Electronic Frontier Foundation
>
>
>
