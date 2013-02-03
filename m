From: =?UTF-8?B?RMOibmllbA==?= Fraga <fragabr@gmail.com>
Subject: Re: Annoying e1000e link up and down issue (workaround)
Date: Sun, 3 Feb 2013 04:34:09 -0200
Message-ID: <kel0d0$qps$1@ger.gmane.org>
References: <kekr0s$kah$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43359 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363Ab3BCGeZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 01:34:25 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U1t9z-0000u3-W6
	for netdev@vger.kernel.org; Sun, 03 Feb 2013 07:34:40 +0100
Received: from 189-69-194-65.dial-up.telesp.net.br ([189.69.194.65])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 07:34:39 +0100
Received: from fragabr by 189-69-194-65.dial-up.telesp.net.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 07:34:39 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 3 Feb 2013 02:02:23 -0200
D=C3=A2niel Fraga <fragabr@gmail.com> wrote:

> 	Can someone take a look at this bug?
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D53291

	Well, my workaround is to turn off (unplug from AC power) the
TP-Link WDR4300, wait a few minutes and turn it on. Then e1000e will
autonegotiate 1000 Mbps correctly.

	The question is: the problem is with the router or with the
e1000e driver? Since many users are having the same problem, couldn't
e1000e deal with it in a better way?

--=20
Linux 3.7.0: Terrified Chipmunk
http://www.youtube.com/DanielFragaBR
http://www.libertarios.org.br
