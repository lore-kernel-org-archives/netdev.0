From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: [RFC PATCH net-next v2 0/1] Add support of ECMPv6
Date: Mon, 15 Oct 2012 21:54:48 +0200
Message-ID: <m3y5j7lddj.fsf@neo.luffy.cx>
References: <505058F5.9020707@linux-ipv6.org>
	<1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
	<87392l7xjc.fsf@guybrush.luffy.cx> <5053329F.6030109@6wind.com>
	<c6a5aae8c773f78aaa1c59cfb68a3d52@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:46325 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754377Ab2JOTyw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:54:52 -0400
In-Reply-To: <c6a5aae8c773f78aaa1c59cfb68a3d52@luffy.cx> (Vincent Bernat's
	message of "Mon, 15 Oct 2012 14:36:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 15 octobre 2012 14:36 CEST, Vincent Bernat <bernat@luffy.cx>=
=C2=A0:

> The problem is the same with BIRD. The difference with IPv4 makes it
> difficult to factor the code between IPv4 and IPv6. What do you think=
?

I am in the process of creating the appropriate patches for Quagga and
it is less difficult that I thought. It is possible to plug the
difference between IPv4 and IPv6 for multipath routes right into the
difference between IPv4 single hop and IPv4 multi hop routes that are
also handled differently.

I am still thinking that the approach is confusing for the userland but
it is not really cumbersome from the implementor point of view and it
has also some advantages.
--=20
Make it clear before you make it faster.
            - The Elements of Programming Style (Kernighan & Plauger)
