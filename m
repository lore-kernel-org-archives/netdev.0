From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: [PATCH] Fix "ip -6 route add ... nexthop"
Date: Thu, 06 Sep 2012 19:53:46 +0200
Message-ID: <87a9x3vxzp.fsf@guybrush.luffy.cx>
References: <1346952649-5716-1-git-send-email-bernat@luffy.cx>
	<1346952649-5716-2-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:54280 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932654Ab2IFSBM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 14:01:12 -0400
Received: from bart.luffy.cx (localhost [127.0.0.1])
	by bart.luffy.cx (Postfix) with ESMTP id BB56014203
	for <netdev@vger.kernel.org>; Thu,  6 Sep 2012 19:53:48 +0200 (CEST)
Received: from guybrush.luffy.cx (nat-bureautique.net.b1.fti.net [193.252.118.2])
	by bart.luffy.cx (Postfix) with ESMTPS id 712EC14127
	for <netdev@vger.kernel.org>; Thu,  6 Sep 2012 19:53:48 +0200 (CEST)
In-Reply-To: <1346952649-5716-2-git-send-email-bernat@luffy.cx> (Vincent
	Bernat's message of "Thu, 6 Sep 2012 19:30:49 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6  6 septembre 2012 19:30 CEST, Vincent Bernat <bernat@luffy.c=
x>=C2=A0:

> IPv6 multipath routes were not accepted by "ip route" because an IPv4
> address was expected for each gateway. Use `get_addr()` instead of
> `get_addr32()`.

Well, looking at the kernel, I have just discovered that there is no
support for IPv6 multipath. This explains a lot of things for me and
this patch is therefore useless (but could still be applied for future
purposes?).
--=20
panic("CPU too expensive - making holiday in the ANDES!");
	2.2.16 /usr/src/linux/arch/mips/kernel/traps.c
