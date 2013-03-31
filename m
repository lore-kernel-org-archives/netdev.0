From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Sun, 31 Mar 2013 23:11:47 +0200
Message-ID: <20130331211147.GB4924@order.stressinduktion.org>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com> <20100125.163612.582489483209420341.anders@netinsight.net> <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com> <20100126.093439.651115405791675606.anders@netinsight.net> <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anders =?utf-8?Q?Bostr=C3=B6m?= <anders@netinsight.net>,
	Jie.Yang@Atheros.com, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41994 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab3CaVLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 17:11:49 -0400
Content-Disposition: inline
In-Reply-To: <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 31, 2013 at 12:25:58AM +0000, Ben Hutchings wrote:
> On Tue, 2010-01-26 at 09:34 +0100, Anders Bostr=C3=B6m wrote:
> > >>>>> "JY" =3D=3D Jie Yang <Jie.Yang@Atheros.com> writes:
> >=20
> >  JY> Anders Bostr=C3=B6m <anders@netinsight.net> wrote:
> >=20
> >  JY> following is my test cese,
> >  >>=20
> >  JY> a nfs server server with ar8131chip, device id 1063.
> >  >> export /tmp/ dir as the nfs share directory,  JY> the client,
> >  >> mount the server_ip:/tmp to local dir /mnt/nfs, ust a python
> >  >> script to write and read data on the  JY>
> >  >> /mnt/nfs/testnfs.log. it works fine.
> >  >>=20
> >  >> OK, the device-ID in our NFS-server is 1026, rev. b0. So it
> >  >> is possible that the problem is specific to that chip/version.
> >  JY> oops, its my mistake in writing, my case is 1026 device ID
> >=20
> >  >>=20
> >  JY> Can you give me some advice on how to reproduce this bug??
> >  >>=20
> >  >> The only suggestion I have is to try to find a board with a
> >  >> 1026-chip on it.
> >  >>=20
> >  >> My test-case is just copy of a 1 Gbyte file from the
> >  >> NFS-server to /dev/null , after making sure that the file
> >  >> isn't cached on the client by reading huge amounts of other dat=
a.
> >  >>=20
> >  JY> just to check, if the kernel version is 2.6.26-2 ??
> >=20
> > I've tested with
> > Debian linux-image-2.6.26-2-amd64 version 2.6.26-19lenny2,
> > Debian linux-image-2.6.30-bpo.2-amd64 version 2.6.30-8~bpo50+2 and
> > kernel.org 2.6.30.10 amd64 with ethtool patch for setting of tso. S=
ame
> > result.
>=20
> Does booting with the kernel parameter 'pci=3Dnomsi' avoid the proble=
m?

Thanks Ben for bringing this up.

I'll have a look if I can reproduce it in the next days and if I'll try=
 to
find a workaround.
