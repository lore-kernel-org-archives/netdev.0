From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: Linux vs FreeBSD Which is correct.
Date: Wed, 17 Aug 2011 20:17:48 +0300
Message-ID: <201108172017.48683.remi@remlab.net>
References: <4E4BF456.9000807@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:60675 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754201Ab1HQR0j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 13:26:39 -0400
In-Reply-To: <4E4BF456.9000807@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 ao=FBt 2011 20:03:18 Stephen Clark, vous avez =E9crit :
> I have run into a situation where if I ping our HQ the response comes
> back on a different
> interface than what the request went out on. FreeBSD is happy and say=
s
> it got the response,
> Linux is not and gives no indication it got a response.
>=20
> So is FreeBSD wrong or is Linux wrong?

Most distributions enable reverse path filtering by default.
It can be disabled:
# echo -n 0 > /proc/sys/net/ipv4/conf/all/rp_filter

But you should probably fix the configuration instead (e.g. /etc/sysctl=
=2Econf).

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
