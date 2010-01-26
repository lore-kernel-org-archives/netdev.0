From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Tue, 26 Jan 2010 10:04:25 +0800
Message-ID: <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
References: <CDAFEDABF718A54BABD0DA5476695307455062E7@SHEXMB-01.global.atheros.com>
	<20100121.174247.769487074466946522.anders@netinsight.net>
	<CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
 <20100125.163612.582489483209420341.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>,
	Xiong Huang <Xiong.Huang@Atheros.com>
To: =?iso-8859-1?Q?Anders_Bostr=F6m?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:37164 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751450Ab0AZCE3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 21:04:29 -0500
In-Reply-To: <20100125.163612.582489483209420341.anders@netinsight.net>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anders Bostr=F6m <anders@netinsight.net> wrote:
>> IP-header length field, but is shorter.
>  >>
>  JY> following is my test cese,
>
>  JY> a nfs server server with ar8131chip, device id 1063.
> export /tmp/ dir as the nfs share directory,  JY> the client,
> mount the server_ip:/tmp to local dir /mnt/nfs, ust a python
> script to write and read data on the  JY>
> /mnt/nfs/testnfs.log. it works fine.
>
> OK, the device-ID in our NFS-server is 1026, rev. b0. So it
> is possible that the problem is specific to that chip/version.
oops, its my mistake in writing, my case is 1026 device ID

>
>  JY> Can you give me some advice on how to reproduce this bug??
>
> The only suggestion I have is to try to find a board with a
> 1026-chip on it.
>
> My test-case is just copy of a 1 Gbyte file from the
> NFS-server to /dev/null , after making sure that the file
> isn't cached on the client by reading huge amounts of other data.
>
just to check, if the kernel version is 2.6.26-2 ??

Best wishes
jie
