From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 18:52:27 +0200
Message-ID: <200901071852.32078.rdenis@simphalempin.com>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:40914 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752506AbZAGQvy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:51:54 -0500
In-Reply-To: <20090107114703.GB28161@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 7 janvier 2009 13:47:03 Evgeniy Polyakov, vous avez =E9crit=
=A0:
> The same goal can be achieved with 'owner' iptables match module btw.

Err no. iptables is _not_ suitable for userland applications dropping t=
heir=20
_own_ privileges. For privileged processes, it's clumsy at best, as ipt=
ables=20
does not quite work if more than one applications uses it. That's typic=
ally=20
your firewall configuration wizard or some custom admin-made script.
As for UNprivileged processes, iptables is not allowed.

As I understand it, Michael is trying to build something similar to SEC=
COMP,=20
only way less restrictive and way more usable by real-life userland pro=
grams.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
