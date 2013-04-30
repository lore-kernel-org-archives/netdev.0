From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Tue, 30 Apr 2013 15:04:29 -0400 (EDT)
Message-ID: <20130430.150429.2067963419827466386.davem@davemloft.net>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
	<1367311395-15891-5-git-send-email-amwang@redhat.com>
	<87r4hscr7s.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amwang@redhat.com, netdev@vger.kernel.org, dlstevens@us.ibm.com,
	stephen@networkplumber.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932467Ab3D3TEb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:04:31 -0400
In-Reply-To: <87r4hscr7s.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Tue, 30 Apr 2013 11:17:43 +0200

> Cong Wang <amwang@redhat.com> writes:
>=20
>> +/* Create UDP socket for encapsulation receive. AF_INET6 socket
>> + * could be used for both IPv4 and IPv6 communications.
>> + */
>=20
> This is not necessarily true as mentioned by David Stevens, and acked=
 by
> you here: http://www.spinics.net/lists/netdev/msg234151.html
>=20
> Please take your time to clean up your todo-list and *test* the resul=
t
> with different runtime and buildtime settings. There is no need to ru=
sh
> this, and people may get tired of looking at the same shortcomings ov=
er
> and over again.

+1
