From: Fan Du <fan.du@windriver.com>
Subject: Re: Kernel Panic in IPv6 vxlan
Date: Wed, 27 Nov 2013 16:25:30 +0800
Message-ID: <5295AC7A.8020502@windriver.com>
References: <CAM3m09T2tuFCMjzdJq7AVBDnPeK0kVKt51JXsE954cHO6u_u2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <amwang@redhat.com>
To: Ryan Whelan <rcwhelan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:56054 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810Ab3K0IZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 03:25:35 -0500
In-Reply-To: <CAM3m09T2tuFCMjzdJq7AVBDnPeK0kVKt51JXsE954cHO6u_u2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hallo,

On 2013=E5=B9=B411=E6=9C=8827=E6=97=A5 05:41, Ryan Whelan wrote:
> I'm not sure if this is the right place to report this- please correc=
t
> me if I'm mistaken.
>
> When creating a vxlan interface with an IPv6 multicast group but not
> specifying an underlying device, the kernel panics when the vxlan
> interface is brought up.  This doesn't happen with an IPv4 multicast
> group.  Linux 3.12.1 x86_64
>
> `ip link add vxlan0 type vxlan id 42 group ff0e::110`

You forgot to attach vxlan0 to a physical netdev ;) try:

ip link add vxlan0 type vxlan id 42 group ff0e::110 dev ethX

This will work anyway.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan fan
