From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: kernel BUG at net/core/dev.c:1383 skb_checksum_help:
 BUG_ON(offset > (int)skb->len)
Date: Sun, 14 Oct 2007 22:20:37 +0200
Message-ID: <20071014222037.7fa28640@inria.fr>
References: <20071006141506.785a6683@localhost.localdomain>
	<20071014192640.35065e73@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:32826 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763260AbXJNUXX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 16:23:23 -0400
Received: from smtp3-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp3-g19.free.fr (Postfix) with ESMTP id 2FE7E17B562
	for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 22:23:22 +0200 (CEST)
Received: from localhost.localdomain (bar06-2-82-224-157-131.fbx.proxad.net [82.224.157.131])
	by smtp3-g19.free.fr (Postfix) with ESMTP id EA02517B575
	for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 22:23:21 +0200 (CEST)
In-Reply-To: <20071014192640.35065e73@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Sun, 14 Oct 2007 19:26:40 +0200,
Guillaume Chazarain <guichaz@yahoo.fr> a =C3=A9crit :

> #0  0xc02c9d5e in skb_checksum_help (skb=3D0xe218dcb0) at net/core/de=
v.c:1372
> 1372            BUG_ON(offset > (int)skb->len);

Just another data point, it seems that running the standard Bittorrent
client helps triggering the bug.

Thanks.

--=20
Guillaume
