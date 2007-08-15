From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] [IPv6]: Invalid semicolon after if statement
Date: Wed, 15 Aug 2007 19:52:20 -0400
Message-ID: <20070815235219.GA17004@redhat.com>
References: <Pine.LNX.4.64.0708151509520.15670@kivilampi-30.cs.helsinki.fi> <20070815.150814.82381935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762627AbXHOXwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 19:52:24 -0400
Content-Disposition: inline
In-Reply-To: <20070815.150814.82381935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 03:08:14PM -0700, David Miller wrote:
 > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
 > Date: Thu, 16 Aug 2007 00:57:00 +0300 (EEST)
 >=20
 > > A similar fix to netfilter from Eric Dumazet inspired me to
 > > look around a bit by using some grep/sed stuff as looking for
 > > this kind of bugs seemed easy to automate. This is one of them
 > > I found where it looks like this semicolon is not valid.
 > >=20
 > > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
 >=20
 > Yikes!  Makes you want to audit the entire tree for these
 > things :-)))
=20
Indeed.  Here's another one.


Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/netfilter/xt_u32.c b/net/netfilter/xt_u32.c
index 74f9b14..bec4279 100644
--- a/net/netfilter/xt_u32.c
+++ b/net/netfilter/xt_u32.c
@@ -36,7 +36,7 @@ static bool u32_match_it(const struct xt_u32 *data,
 		at  =3D 0;
 		pos =3D ct->location[0].number;
=20
-		if (skb->len < 4 || pos > skb->len - 4);
+		if (skb->len < 4 || pos > skb->len - 4)
 			return false;
=20
 		ret   =3D skb_copy_bits(skb, pos, &n, sizeof(n));


--=20
http://www.codemonkey.org.uk
