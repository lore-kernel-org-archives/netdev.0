From: Phil Sutter <n0-1@freewrt.org>
Subject: Re: [PATCH] korina: fix handling tx_chain_tail
Date: Wed, 14 Jan 2009 19:21:38 +0100
Message-ID: <20090114181822.F3EC14043831@mail.nwl.cc>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955510-12240-1-git-send-email-n0-1@freewrt.org> <200901141900.14616.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:37819 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447AbZANSYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 13:24:41 -0500
Content-Disposition: inline
In-Reply-To: <200901141900.14616.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 07:00:14PM +0100, Florian Fainelli wrote:
> Le Wednesday 14 January 2009 18:51:50 Phil Sutter, vous avez =C3=A9cr=
it=C2=A0:
> > Originally this must have been a rewrite error when introducing
> > 'chain_index'. But the original driver did not use the previous cha=
in
> > item everywhere: when altering the address tx_chain_tail points to,=
 it
> > should move forward, not backwards.
>=20
> I think this was in the original driver as well.

Yes, indeed.

Greetings, Phil
