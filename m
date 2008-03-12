From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: question regarding (AF_INET6, SOCK_RAW, IPPROTO_RAW) sockets
Date: Thu, 13 Mar 2008 01:02:02 +0200
Message-ID: <200803130102.02366.opurdila@ixiacom.com>
References: <200803121834.29293.opurdila@ixiacom.com> <200803122006.49506.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3628 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751744AbYCLXBR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 19:01:17 -0400
In-Reply-To: <200803122006.49506.rdenis@simphalempin.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 12 March 2008, R=C3=A9mi Denis-Courmont wrote:

>
> I am a bit confused here. Why would you use IPV6_PKTINFO with a
> network-layer raw socket? You have to write the IPv6 header anyway, s=
o what
> useful additional infos would you the ancillary data contain?


Hi R=C3=A9mi,

You are right. For some reason (the IPV4 case / man 7 raw) I though tha=
t=20
IPV6_PKTINFO is implied when using IPPROTO_RAW but I see now that it is=
 not=20
required.

Thanks,
tavi
