From: Anders =?iso-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Tue, 26 Jan 2010 09:34:39 +0100 (CET)
Message-ID: <20100126.093439.651115405791675606.anders@netinsight.net>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
	<20100125.163612.582489483209420341.anders@netinsight.net>
	<CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: Jie.Yang@Atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:8452 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751864Ab0AZIet convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 03:34:49 -0500
In-Reply-To: <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "JY" =3D=3D Jie Yang <Jie.Yang@Atheros.com> writes:

 JY> Anders Bostr=F6m <anders@netinsight.net> wrote:

 JY> following is my test cese,
 >>=20
 JY> a nfs server server with ar8131chip, device id 1063.
 >> export /tmp/ dir as the nfs share directory,  JY> the client,
 >> mount the server_ip:/tmp to local dir /mnt/nfs, ust a python
 >> script to write and read data on the  JY>
 >> /mnt/nfs/testnfs.log. it works fine.
 >>=20
 >> OK, the device-ID in our NFS-server is 1026, rev. b0. So it
 >> is possible that the problem is specific to that chip/version.
 JY> oops, its my mistake in writing, my case is 1026 device ID

 >>=20
 JY> Can you give me some advice on how to reproduce this bug??
 >>=20
 >> The only suggestion I have is to try to find a board with a
 >> 1026-chip on it.
 >>=20
 >> My test-case is just copy of a 1 Gbyte file from the
 >> NFS-server to /dev/null , after making sure that the file
 >> isn't cached on the client by reading huge amounts of other data.
 >>=20
 JY> just to check, if the kernel version is 2.6.26-2 ??

I've tested with
Debian linux-image-2.6.26-2-amd64 version 2.6.26-19lenny2,
Debian linux-image-2.6.30-bpo.2-amd64 version 2.6.30-8~bpo50+2 and
kernel.org 2.6.30.10 amd64 with ethtool patch for setting of tso. Same
result.

/ Anders
