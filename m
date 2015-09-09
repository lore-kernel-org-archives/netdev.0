From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH v2] net: ipv6: use common fib_default_rule_pref
Date: Wed, 9 Sep 2015 13:45:37 +0200
Message-ID: <20150909114537.GP7029@orbit.nwl.cc>
References: <20150905.220040.768580139044156666.davem@davemloft.net>
 <1441534858-6452-1-git-send-email-phil@nwl.cc>
 <20150908.223705.1178974104676916256.davem@davemloft.net>
 <20150908.223809.1598957585735076244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:52039 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbbIILpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 07:45:41 -0400
Content-Disposition: inline
In-Reply-To: <20150908.223809.1598957585735076244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 08, 2015 at 10:38:09PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 08 Sep 2015 22:37:05 -0700 (PDT)
>=20
> > Applied, thanks.
>=20
> Actually, reverted, this doesn't even compile.
>=20
> net/core/fib_rules.c:47:12: error: static declaration of =E2=80=98fib=
_default_rule_pref=E2=80=99 follows non-static declaration
>  static u32 fib_default_rule_pref(struct fib_rules_ops *ops)
>             ^
> In file included from net/core/fib_rules.c:18:0:
> include/net/fib_rules.h:120:5: note: previous declaration of =E2=80=98=
fib_default_rule_pref=E2=80=99 was here
>  u32 fib_default_rule_pref(struct fib_rules_ops *ops);
>      ^

What the heck? I should throw away the optimizer, it seems to make me
skip testing sometimes. Sorry for the mess, I'll follow up with a fixed
and *tested* version.

Cheers, Phil
