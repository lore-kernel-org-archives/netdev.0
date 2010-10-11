From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Mon, 11 Oct 2010 18:30:52 +0200
Message-ID: <1286814652.2737.41.camel@edumazet-laptop>
References: <1286810413-30238-1-git-send-email-avagin@openvz.org>
	 <4CB32FDB.4090001@msgid.tls.msk.ru>
	 <1286812009.2737.30.camel@edumazet-laptop>
	 <20101011.085952.193718228.davem@davemloft.net>
	 <4CB33907.5060803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mjt@tls.msk.ru,
	avagin@openvz.org, stable@kernel.org, netdev@vger.kernel.org,
	krkumar2@in.ibm.com
To: avagin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35168 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366Ab0JKQa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 12:30:59 -0400
Received: by wwj40 with SMTP id 40so3943270wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 09:30:58 -0700 (PDT)
In-Reply-To: <4CB33907.5060803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 20:19 +0400, Andrew Vagin a =C3=A9crit =
:
> On 10/11/2010 07:59 PM, David Miller wrote:
> > From: Eric Dumazet<eric.dumazet@gmail.com>
> > Date: Mon, 11 Oct 2010 17:46:49 +0200
> >
> >> This patch was an optimization, not a bug fix.
> > Right, this has no business going into 2.6.32-stable at all.
> This is bug fix. Now nobody drops dst in case gso and veth, because t=
he=20
> commit 60df914e295a21a223e43a7ee01e0c73c64dd111 deletes skb_dst_drop=20
> from the veth.c. We should commit my patch or revert commit 60df914e.
>=20
> We have two bug reports:
>=20
> http://www.spinics.net/lists/netdev/msg142104.html
>=20
> http://bugzilla.openvz.org/show_bug.cgi?id=3D1634
>=20
> Taylan verified that the patch really fix his bug.

Now that makes sense ;)

This is always good to mention commit id of a bug origin.

Because reading your patch (changelog and content), it was not obvious
it fixed a bug.

Thanks !


