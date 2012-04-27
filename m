From: =?windows-1252?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Sat, 28 Apr 2012 01:05:37 +0200
Message-ID: <4F9B2641.9070209@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120427134127.6d536a96@nehalam.linuxnetplumber.net> <20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:54430 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756523Ab2D0XEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 19:04:48 -0400
In-Reply-To: <20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't compile against 3.4-rc4:

   CC [M]  drivers/net/ethernet/intel/e1000e/param.o
   CC [M]  drivers/net/ethernet/marvell/sky2.o
   CC [M]  drivers/net/ethernet/intel/e1000e/ethtool.o
   CC [M]  net/sunrpc/svc_xprt.o
drivers/net/ethernet/marvell/sky2.c: In function =91sky2_status_intr=92=
:
drivers/net/ethernet/marvell/sky2.c:2769:4: warning: passing argument 2=
=20
of =91sky2_skb_rx=92 makes pointer from integer without a cast
drivers/net/ethernet/marvell/sky2.c:2649:20: note: expected =91struct=20
sk_buff *=92 but argument is of type =91u32=92
drivers/net/ethernet/marvell/sky2.c:2769:4: error: too many arguments t=
o=20
function =91sky2_skb_rx=92
drivers/net/ethernet/marvell/sky2.c:2649:20: note: declared here
make[4]: *** [drivers/net/ethernet/marvell/sky2.o] Errore 1
make[3]: *** [drivers/net/ethernet/marvell] Errore 2
make[3]: *** Attesa dei processi non terminati....
   CC [M]  net/sunrpc/backchannel_rqst.o
   CC [M]  drivers/net/ethernet/intel/e1000e/netdev.o


Niccol=F2
