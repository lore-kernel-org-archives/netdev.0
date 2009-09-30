From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Wed, 30 Sep 2009 07:51:21 +0200
Message-ID: <4AC2F1D9.1010801@gmail.com>
References: <20090930004820.GC19540@obsidianresearch.com> <4AC2E481.5060509@gmail.com> <20090930054031.GY22310@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32797 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbZI3Fv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 01:51:27 -0400
In-Reply-To: <20090930054031.GY22310@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Gunthorpe a =E9crit :
>> One way to handle this is to switch tcp_read() to use the underlying=
 file O_NONBLOCK
>> flag, as other socket operations do. And let SPLICE_F_NONBLOCK contr=
ol the pipe output only.

arg, this was tcp_splice_read() of course

>=20
> Thanks Eric, this seems reasonable from my userspace perspective.
>=20
> I admit I don't understand why SPLICE_F_NONBLOCK exists, it seems ver=
y
> un-unixy to have a syscall completely ignore the NONBLOCK flag of the
> fd it is called on. Ie setting NONBLOCK on the pipe itself does
> nothing when using splice..
>=20

Hmm, good question, I dont have the answer but I'll digg one.
