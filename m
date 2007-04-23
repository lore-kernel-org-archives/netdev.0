From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH/RESEND] ehea: fix for dlpar and sysfs entries
Date: Mon, 23 Apr 2007 15:54:04 +0200
Message-ID: <200704231554.06110.arnd@arndb.de>
References: <200704231358.53479.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:63982 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbXDWNyP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 09:54:15 -0400
In-Reply-To: <200704231358.53479.ossthema@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 23 April 2007, Jan-Bernd Themann wrote:
> - dlpar fix:=20
> =A0=A0=A0=A0=A0=A0=A0=A0certain resources may only be allocated when =
first
> =A0=A0=A0=A0=A0=A0=A0=A0logical port is available, and must be remove=
d when
> =A0=A0=A0=A0=A0=A0=A0=A0last logical port has been removed
>=20
> - sysfs entries:
> =A0=A0=A0=A0=A0=A0=A0=A0create symbolic link from each logical port t=
o ehea driver
>=20

I can't see anything wrong with the patch contents, but if you know tha=
t there
are two changes, you really should make it two separate patches.

	Arnd <><
