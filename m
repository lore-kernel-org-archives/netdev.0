From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: MAC address runtime configuration in new driver (was Re: ...no subject)
Date: Sun, 11 Jan 2009 16:12:14 +0100
Message-ID: <496A0C4E.5040502@s5r6.in-berlin.de>
References: <204164.94418.qm@web34403.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joseluismarchetti@yahoo.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:44080 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbZAKPMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 10:12:23 -0500
In-Reply-To: <204164.94418.qm@web34403.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jose Luis Marchetti wrote:
> Hi,
>=20
> I would like to open/read/write/close a regular file from my device
> driver.
> I think it would be possible, but I am confused, the "The Linux Kerne=
l
> Module Programming Guide" states that I can not use standard librarie=
s
> from within a module, I know the standard library ends up calling
> system calls, but which calls should I use to deal with regular
> files ?

http://kernelnewbies.org/FAQ/WhyWritingFilesFromKernelIsBad discusses t=
his.

> I am developing a Ethernet driver and the Mac address configuration
>=20
> Thanks in advance!
>=20
> Jos=E9 Lu=EDs Marchetti

Userspace could write the necessary configuration data into the kernel,
for example a sysfs attribute.  Of course the attribute could also be
readable.  But perhaps there are already established mechanisms for
exactly this purpose.  I added Cc: netdev, maybe somebody there can giv=
e
advice.
--=20
Stefan Richter
-=3D=3D=3D=3D=3D-=3D=3D--=3D ---=3D -=3D-=3D=3D
http://arcgraph.de/sr/
