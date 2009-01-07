From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 20:48:09 +0300
Message-ID: <20090107174809.GA8989@ioremap.net>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net> <200901071852.32078.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?utf-8?B?UsOpbWk=?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:41507 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752719AbZAGRsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 12:48:12 -0500
Content-Disposition: inline
In-Reply-To: <200901071852.32078.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 06:52:27PM +0200, R=C3=A9mi Denis-Courmont (rde=
nis@simphalempin.com) wrote:
> Le mercredi 7 janvier 2009 13:47:03 Evgeniy Polyakov, vous avez =C3=A9=
crit=C2=A0:
> > The same goal can be achieved with 'owner' iptables match module bt=
w.
>=20
> Err no. iptables is _not_ suitable for userland applications dropping=
 their=20
> _own_ privileges. For privileged processes, it's clumsy at best, as i=
ptables=20
> does not quite work if more than one applications uses it. That's typ=
ically=20
> your firewall configuration wizard or some custom admin-made script.
> As for UNprivileged processes, iptables is not allowed.

If setting that rlimit does not require admin priviledges, then it does
not require to drop this. So it is superuser or admin who does this.
And exactly the same can be achieved with 'owner' iptables module.

If process itself changes own rlimit, then it is not a rlimit, but a
hint to how it is supposed to work.

Plus I did not see how fork is protected, i.e. does children get the
same rlimit, it looks like it does not.

> As I understand it, Michael is trying to build something similar to S=
ECCOMP,=20
> only way less restrictive and way more usable by real-life userland p=
rograms.

Security and unpriveledged setup are mutually impossible cases.

--=20
	Evgeniy Polyakov
