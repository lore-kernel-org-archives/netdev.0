From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: =?UTF-8?Q?IPV=36=5FRTHDR=20with=20a=20type-=30=20routing=20header?=
Date: Thu, 20 Aug 2009 13:29:09 +0200
Message-ID: <7d4abbaea1f1e17050a0e8ffe4917cb8@chewa.net>
References: <20090820111152.GA20295@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:46048 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260AbZHTL3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 07:29:08 -0400
In-Reply-To: <20090820111152.GA20295@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 20 Aug 2009 13:11:52 +0200, "Steinar H. Gunderson"=0D
<sgunderson@bigfoot.com> wrote:=0D
> I've tried attaching a type-0 routing header to my IPv6 packets with=0D
> setsockopt(..., IPV6_RTHDR, ...), but the kernel just returns EINVAL.=
=0D
> looking at the source, it seems it simply refuses anything that's not=
=0D
> type-2;=0D
> should that really be right? I found the following commit:=0D
=0D
RT0 headers have been deprecated by IETF. The kernel refuses to use the=
n on=0D
purpose.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

