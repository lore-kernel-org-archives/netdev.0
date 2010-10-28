From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: IPV6 raw socket denies bind(2)
Date: Thu, 28 Oct 2010 10:25:03 +0200
Message-ID: <14731dd6a7f7fda9e6a1704ce1fbc5a7@chewa.net>
References: <alpine.LNX.2.01.1010280000260.7820@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:44585 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933149Ab0J1IZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 04:25:05 -0400
In-Reply-To: <alpine.LNX.2.01.1010280000260.7820@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 28 Oct 2010 00:01:57 +0200 (CEST), Jan Engelhardt=0D
<jengelh@medozas.de> wrote:=0D
> #include <sys/socket.h>=0D
> #include <stdio.h>=0D
> #include <string.h>=0D
> #include <netinet/udp.h>=0D
> #include <netinet/in.h>=0D
> #include <netinet/ip6.h>=0D
> #include <arpa/inet.h>=0D
> #include <stdlib.h>=0D
> =0D
> int main(void)=0D
> {=0D
> 	struct sockaddr_in6 src =3D {};=0D
> 	int sk;=0D
> =0D
> 	sk =3D socket(AF_INET6, SOCK_RAW, IPPROTO_UDP);=0D
> 	memset(&src, 0, sizeof(src));=0D
> 	inet_pton(AF_INET6, "::1", &src);=0D
=0D
That should be:=0D
inet_pton(AF_INET6, "::1", &src.sin6_addr);=0D
No wonder it does not work.=0D
=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

