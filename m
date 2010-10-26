From: David Miller <davem@davemloft.net>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Tue, 26 Oct 2010 11:54:34 -0700 (PDT)
Message-ID: <20101026.115434.241921999.davem@davemloft.net>
References: <20101011.085952.193718228.davem@davemloft.net>
	<4CB33907.5060803@gmail.com>
	<1286814652.2737.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avagin@gmail.com, mjt@tls.msk.ru, avagin@openvz.org,
	stable@kernel.org, netdev@vger.kernel.org, krkumar2@in.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754233Ab0JZSyL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 14:54:11 -0400
In-Reply-To: <1286814652.2737.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 18:30:52 +0200

> Le lundi 11 octobre 2010 =E0 20:19 +0400, Andrew Vagin a =E9crit :
>> On 10/11/2010 07:59 PM, David Miller wrote:
>> > From: Eric Dumazet<eric.dumazet@gmail.com>
>> > Date: Mon, 11 Oct 2010 17:46:49 +0200
>> >
>> >> This patch was an optimization, not a bug fix.
>> > Right, this has no business going into 2.6.32-stable at all.
>> This is bug fix. Now nobody drops dst in case gso and veth, because =
the=20
>> commit 60df914e295a21a223e43a7ee01e0c73c64dd111 deletes skb_dst_drop=
=20
>> from the veth.c. We should commit my patch or revert commit 60df914e=
=2E
>>=20
>> We have two bug reports:
>>=20
>> http://www.spinics.net/lists/netdev/msg142104.html
>>=20
>> http://bugzilla.openvz.org/show_bug.cgi?id=3D1634
>>=20
>> Taylan verified that the patch really fix his bug.
>=20
> Now that makes sense ;)

In case there is any doubt about this -stable patch submission:

Acked-by: David S. Miller <davem@davemloft.net>
