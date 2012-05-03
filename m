From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: sky2 still badly broken
Date: Thu, 03 May 2012 20:06:11 +0200
Message-ID: <4FA2C913.4080504@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net> <4FA14EC6.6050207@linuxsystems.it> <20120502115618.04ab8ff9@s6510.linuxnetplumber.net> <4FA2527A.6020808@linuxsystems.it> <20120503082352.771acab3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:47247 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab2ECSFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 14:05:05 -0400
In-Reply-To: <20120503082352.771acab3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 03/05/2012 17:23, Stephen Hemminger ha scritto:
> The receiver on some versions of the chip can't keep up with full spe=
ed
> of 1G bit/sec. The receive  FIFO has hardware issues, and since I don=
't
> work for Marvell, working around the problem is guesswork. Without ex=
act
> information all that can be done is have a timeout and blunt force re=
set
> logic. The vendor driver sk98lin has the same brute force logic, but =
may
> just not print the message.

If I lower the speed to 100Mb/s I don't have rx errors anymore *BUT*=20
when using dhcp after a while the network doesn't work anymore:

64 bytes from 8.8.8.8: icmp_req=3D590 ttl=3D47 time=3D61.7 ms
64 bytes from 8.8.8.8: icmp_req=3D591 ttl=3D47 time=3D62.0 ms
64 bytes from 8.8.8.8: icmp_req=3D592 ttl=3D47 time=3D62.0 ms
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable


I have no problems with dhcp using wifi or other NICs.

Niccol=F2
