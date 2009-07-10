From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv7 2/2] memory barrier: adding smp_mb__after_lock
Date: Thu, 09 Jul 2009 17:08:11 -0700 (PDT)
Message-ID: <20090709.170811.21077750.davem@davemloft.net>
References: <20090708220717.GB2945@jolsa.redhat.com>
	<20090708221031.GD2945@jolsa.redhat.com>
	<4A557153.8000108@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jolsa@redhat.com, netdev@vger.kernel.org,
	mathieu.desnoyers@polymtl.ca, mingo@elte.hu,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, htejun@gmail.com,
	jarkao2@gmail.com, oleg@redhat.com, davidel@xmailserver.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751873AbZGJAII convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 20:08:08 -0400
In-Reply-To: <4A557153.8000108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jul 2009 06:25:55 +0200

> Jiri Olsa a =E9crit :
>> Adding smp_mb__after_lock define to be used as a smp_mb call after
>> a lock.
>>=20
>> Making it nop for x86, since {read|write|spin}_lock() on x86 are
>> full memory barriers.
>>=20
>> wbr,
>> jirka
>>=20
>>=20
>> Signed-off-by: Jiri Olsa <jolsa@redhat.com>
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks everyone!
