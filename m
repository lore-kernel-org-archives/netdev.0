From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 01:59:46 +0100
Message-ID: <4F458F82.3060808@linuxsystems.it>
References: <bug-42809-100@https.bugzilla.kernel.org/> <20120222092056.5fca788b@nehalam.linuxnetplumber.net> <4F4528CE.7080702@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, support@traverse.com.au,
	support@rocksolidelectronics.com, 660804@bugs.debian.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:51546 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab2BWA7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 19:59:40 -0500
In-Reply-To: <4F4528CE.7080702@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
The bug is still present in latest 3.2.7 vanilla kernel. I wasted the=20
whole day debugging that damn thing and I finally discovered the root c=
ause.
The problem is with my Traverse Solos multi-port ADSL2+ PCI card[1]=20
(which has open source drivers included in the kernel) when using RFC=20
2684 routed.
I have two adsl lines, the first one connected using RFC 2684 routed,=20
the second one using PPPoA.
If I create a vpn toward the PPPoA line it works flawlessly, while if I=
=20
create a vpn toward the RFC 2684 routed line the whole system hangs in =
a=20
kernel panic (with both 2.6.32.54 and 3.2.7).
I really don't know how to fix it and I need to setup that damn ipsec v=
pn :(

This is the bug on bugzilla.kernel.org:
https://bugzilla.kernel.org/show_bug.cgi?id=3D42809

Niccol=F2


[1]http://www.traverse.com.au/productview.php?product_id=3D116
