From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sun, 20 Mar 2011 11:04:41 +0200
Message-ID: <201103201104.42183.remi@remlab.net>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net> <1300609817.2831.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:49476 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751621Ab1CTJEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 05:04:45 -0400
In-Reply-To: <1300609817.2831.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 mars 2011 10:30:17 Eric Dumazet, vous avez =C3=A9crit :
>=20
> But application also needs to use : listen(fd, 8192)

Application should pass INT_MAX anyway, unless it has a specific limit,=
 e.g.=20
it can only handle one connection at time.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.info/
http://fi.linkedin.com/in/remidenis
