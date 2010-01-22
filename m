From: Rainer Koenig <Rainer.Koenig@ts.fujitsu.com>
Subject: e1000e and  Intel 82578DM, 10 Mbit/s only
Date: Fri, 22 Jan 2010 14:39:33 +0100
Message-ID: <4B59AA95.4050207@ts.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dgate10.ts.fujitsu.com ([80.70.172.49]:12628 "EHLO
	dgate10.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab0AVNtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 08:49:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm currently facing a problem on Intel Ibexpeak mainboards that have
the Intel 82578DM chip for LAN. Device ID is 8086:10ef.

When using the e1000e driver that comes with distributions like
- Fedora 12
- RHEL 5.4
- openSUSE 11.2

then I only get the link up with 10 Mbit/s instead of 1000 Mbit/s.

Driver version is 1.0.2-k2 (according to modinfo)

If I use the e1000e from Sourceforge (Version 1.0.15 or 1.1.2) then
the machine gets the correct Gigabit link.

So some questions on the e1000e kernel driver:

- will the necessary patches be merged from the sourceforge driver to
  the vanilla driver?

- why is the modinfo version so "static" on this driver? I've seen lots
  of patches on the list archives and in git, but modversion seems to b=
e
  an universal constant at "1.0.2-k2"?

The bad impact of this problem is that with this bug of the kernel
driver systems affected by this will not pass trough a Red Hat hardware
certification network test. So guess what my current problem is: yeah,
right I should do hardware certification with this LAN.

Thanks for your attention & regards
Rainer
--=20
Dipl.-Inf. (FH) Rainer Koenig
Project Manager Linux Business Clients
Dept. TSP CLI R&D SW OSE

=46ujitsu Technology Solutions
B=FCrgermeister-Ullrich-Str. 100
86199 Augsburg
Germany

Telephone: +49-821-804-3321
Telefax:   +49-821-804-2131
Mail:      mailto:Rainer.Koenig@ts.fujitsu.com

Internet         ts.fujtsu.com
Company Details  ts.fujitsu.com/imprint.html
