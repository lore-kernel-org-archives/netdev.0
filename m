From: Dave Jones <davej@redhat.com>
Subject: Re: net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards
 compatibility
Date: Thu, 16 May 2013 14:25:10 -0400
Message-ID: <20130516182510.GA4728@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bj=F8rn,

 > Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3D1e8bbe6cd02f=
c300c88bd48244ce61ad9c7d1776
 > Commit:     1e8bbe6cd02fc300c88bd48244ce61ad9c7d1776
 > Parent:     a5b8db91442fce9c9713fcd656c3698f1adde1d6
 > Author:     Bj=F8rn Mork <bjorn@mork.no>
 > AuthorDate: Thu Mar 14 01:05:13 2013 +0000
 > Committer:  David S. Miller <davem@davemloft.net>
 > CommitDate: Sun Mar 17 11:59:03 2013 -0400
 >=20
 >     net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards c=
ompatibility
 >    =20
 >     commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible MBI=
M devices")
 >     introduced a new policy, preferring MBIM for dual NCM/MBIM funct=
ions if
 >     the cdc_mbim driver was enabled.  This caused a regression for u=
sers
 >     wanting to use NCM.
 >    =20
 >     Devices implementing NCM backwards compatibility according to se=
ction
 >     3.2 of the MBIM v1.0 specification allow either NCM or MBIM on a=
 single
 >     USB function, using different altsettings.  The cdc_ncm and cdc_=
mbim
 >     drivers will both probe such functions, and must agree on a comm=
on
 >     policy for selecting either MBIM or NCM.  Until now, this policy=
 has
 >     been set at build time based on CONFIG_USB_NET_CDC_MBIM.
 >    =20
 >     Use a module parameter to set the system policy at runtime, allo=
wing the
 >     user to prefer NCM on systems with the cdc_mbim driver.

Is there any way we can set this automatically based on the type of dev=
ice connected
and have it just work without users needing to edit modprobe.conf ?

Since this change, we've now getting reports like https://bugzilla.redh=
at.com/show_bug.cgi?id=3D963663

	Dave
