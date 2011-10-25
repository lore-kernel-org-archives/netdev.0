From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] net: make bonding slaves honour master's skb->priority
Date: Mon, 24 Oct 2011 21:58:48 -0700
Message-ID: <32080.1319518728@death>
References: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41526 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651Ab1JYE6y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 00:58:54 -0400
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 25 Oct 2011 00:58:53 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9P4wpKM205030
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 00:58:51 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9P4wo2G018792
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 02:58:51 -0200
In-reply-to: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

>From: Maciej =C5=BBenczykowski <maze@google.com>
>
>Change-Id: Ieea6ff9aacacb1eb8c52308c8bfe091acbfc09b2

	The code change itself is ok, but I'm not sure what this
Change-Id is.  With a regular log message, this should be fine to apply=
=2E

	-J


>Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
>---
> drivers/net/bonding/bond_main.c |    1 -
> 1 files changed, 0 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bon=
d_main.c
>index 41430ba..2cbc2f8 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -395,7 +395,6 @@ int bond_dev_queue_xmit(struct bonding *bond, stru=
ct sk_buff *skb,
> 			struct net_device *slave_dev)
> {
> 	skb->dev =3D slave_dev;
>-	skb->priority =3D 1;
>
> 	skb->queue_mapping =3D bond_queue_mapping(skb);
>
>--=20
>1.7.3.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
