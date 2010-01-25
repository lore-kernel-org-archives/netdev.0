From: Anders =?iso-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Mon, 25 Jan 2010 16:36:12 +0100 (CET)
Message-ID: <20100125.163612.582489483209420341.anders@netinsight.net>
References: <CDAFEDABF718A54BABD0DA5476695307455062E7@SHEXMB-01.global.atheros.com>
	<20100121.174247.769487074466946522.anders@netinsight.net>
	<CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: Jie.Yang@Atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:21422 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752421Ab0AYPgV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 10:36:21 -0500
In-Reply-To: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "JY" =3D=3D Jie Yang <Jie.Yang@Atheros.com> writes:

 JY> Anders Bostr=F6m <anders@netinsight.net> wrote:
 >> Cc: ben@decadent.org.uk; netdev@vger.kernel.org;
 >> 565404@bugs.debian.org; Xiong Huang
 >> Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e:
 >> TSO is broken

 >> One strange observation is that I can only reproduce this
 >> problem when transmitting data from a NFS-server using TCP
 >> with Atheros AR8121/AR8113/AR8114.
 >>=20
 >> I've tried to reproduce the problem using test-programs, like
 >> nttcp and netpipe, without any success. One observation is
 >> that the test-programs *only* generates 1500 bytes
 >> IP-packets. When the NFS-server sends data, a sequence of
 >> 1500 bytes IP-packets are generated, ending with a shorter
 >> packet. And this last packet in the sequence has 1500 in the
 >> IP-header length field, but is shorter.
 >>=20
 JY> following is my test cese,

 JY> a nfs server server with ar8131chip, device id 1063. export /tmp/ =
dir as the nfs share directory,
 JY> the client, mount the server_ip:/tmp to local dir /mnt/nfs, ust a =
python script to write and read data on the
 JY> /mnt/nfs/testnfs.log. it works fine.

OK, the device-ID in our NFS-server is 1026, rev. b0. So it is
possible that the problem is specific to that chip/version.

 JY> Can you give me some advice on how to reproduce this bug??

The only suggestion I have is to try to find a board with a 1026-chip
on it.

My test-case is just copy of a 1 Gbyte file from the
NFS-server to /dev/null , after making sure that the file isn't cached
on the client by reading huge amounts of other data.

/ Anders
