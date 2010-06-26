From: Jiri Olsa <jolsa@redhat.com>
Subject: [PATCH 2/2 v2] man - IP_NODEFRAG option for IPv4 socket
Date: Sat, 26 Jun 2010 15:13:15 -0400
Message-ID: <20100626191315.GA2076@jolsa.nomadprime.subscribe.loganwifi.com>
References: <1276600052-16499-1-git-send-email-jolsa@redhat.com>
 <1276600052-16499-3-git-send-email-jolsa@redhat.com>
 <AANLkTim4N5rc8Sn_uo5bXsb9vjvKd3GTQD3p-1uApbB8@mail.gmail.com>
 <20100626.095857.137828263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mtk.manpages@gmail.com, eric.dumazet@gmail.com, jengelh@medozas.de,
	kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-man@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab0FZTNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jun 2010 15:13:24 -0400
Content-Disposition: inline
In-Reply-To: <20100626.095857.137828263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 26, 2010 at 09:58:57AM -0700, David Miller wrote:
> From: Michael Kerrisk <mtk.manpages@gmail.com>
> Date: Sat, 26 Jun 2010 15:01:03 +0200
>=20
> >> =A0sent from this socket.
> >> +.TP
> >> +.BR IP_NODEFRAG " (since Linux 2.6)"
> >=20
> > here, we'd write the exact version in which the flag is added. It
> > looks like that might be 2.36, right?
>=20
> It'll show up in 2.6.36
>=20
> I doubt I'll be alive when we make it to 2.36 :-)

:) ok, attaching changed patch

thanks,
jirka

---
hi,

this patch adds description for IP_NODEFRAG option for IPv4 socket.

wbr,
jirka


Signed-off-by: Jiri Olsa <jolsa@redhat.com>
---
 man7/ip.7 |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/man7/ip.7 b/man7/ip.7
index 34f7e80..12c0d5b 100644
--- a/man7/ip.7
+++ b/man7/ip.7
@@ -705,6 +705,12 @@ socket option (see
 .BR IP_TTL " (since Linux 1.0)"
 Set or retrieve the current time-to-live field that is used in every p=
acket
 sent from this socket.
+.TP
+.BR IP_NODEFRAG " (since Linux 2.6.36)"
+If enabled, the reassembly of outgoing packets is disabled in the netf=
ilter layer.
+Only valid for
+.B SOCK_RAW
+sockets.
 .\" FIXME Document IP_XFRM_POLICY
 .\" Since Linux 2.5.48
 .\" Needs CAP_NET_ADMIN
