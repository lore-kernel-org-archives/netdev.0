From: Sven Hartge <sven@svenhartge.de>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 02:07:11 +0100
Message-ID: <79jo8bjargv8@mids.svenhartge.de>
References: <514CE440.3010003@gmail.com> <1363996448.4431.73.camel@edumazet-glaptop> <514CF23A.3010702@gmail.com> <20130323021008.GC939@order.stressinduktion.org> <514D3581.4040001@gmail.com> <20130323150655.GA10779@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37479 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296Ab3CXBIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Mar 2013 21:08:15 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UJZQK-0007lC-9H
	for netdev@vger.kernel.org; Sun, 24 Mar 2013 02:08:36 +0100
Received: from ip-178-200-42-118.unitymediagroup.de ([178.200.42.118])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 02:08:36 +0100
Received: from sven by ip-178-200-42-118.unitymediagroup.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 02:08:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> The upstream driver (which is a tarball I found with google
> AR81Family-linux-v1.0.1.14.tar.gz) has this function ifdefed out. I
> have a couple of more things I want to test as soon as I have access
> to the hardware again.  If I don't find a better solution I will
> submit a patch which disables rx checksumming as a whole for inclusio=
n
> to net-next.

In addition to my other mail: Please have a look at Debian Bug #558426
<http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D558426> which is ab=
out
TSO and TCP/IPv6 on atl1e which had problems as well.

I wouldn't find it surprising if any offloading or hardware checksummin=
g
is broken on that hardware.

Gr=C3=BC=C3=9Fe,
Sven.

--=20
Sigmentation fault. Core dumped.
