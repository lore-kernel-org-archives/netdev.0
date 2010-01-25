From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Mon, 25 Jan 2010 13:41:19 +0800
Message-ID: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
References: <CDAFEDABF718A54BABD0DA5476695307443F1E8D@SHEXMB-01.global.atheros.com>
	<20100120.102704.295948365864962720.anders@netinsight.net>
	<CDAFEDABF718A54BABD0DA5476695307455062E7@SHEXMB-01.global.atheros.com>
 <20100121.174247.769487074466946522.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>,
	Xiong Huang <Xiong.Huang@Atheros.com>
To: =?iso-8859-1?Q?Anders_Bostr=F6m?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:48092 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750918Ab0AYFlX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 00:41:23 -0500
In-Reply-To: <20100121.174247.769487074466946522.anders@netinsight.net>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anders Bostr=F6m <anders@netinsight.net> wrote:

> Cc: ben@decadent.org.uk; netdev@vger.kernel.org;
> 565404@bugs.debian.org; Xiong Huang
> Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e:
> TSO is broken

> One strange observation is that I can only reproduce this
> problem when transmitting data from a NFS-server using TCP
> with Atheros AR8121/AR8113/AR8114.
>
> I've tried to reproduce the problem using test-programs, like
> nttcp and netpipe, without any success. One observation is
> that the test-programs *only* generates 1500 bytes
> IP-packets. When the NFS-server sends data, a sequence of
> 1500 bytes IP-packets are generated, ending with a shorter
> packet. And this last packet in the sequence has 1500 in the
> IP-header length field, but is shorter.
>
following is my test cese,

a nfs server server with ar8131chip, device id 1063. export /tmp/ dir a=
s the nfs share directory,
the client, mount the server_ip:/tmp to local dir /mnt/nfs, ust a pytho=
n script to write and read data on the
/mnt/nfs/testnfs.log. it works fine.

Can you give me some advice on how to reproduce this bug??

Best wishes
jie
