From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfq: deadlock in error path
Date: Wed, 02 Feb 2011 20:51:29 -0800 (PST)
Message-ID: <20110202.205129.71116059.davem@davemloft.net>
References: <20110202171951.09b89d92@nehalam>
	<1296697862.4434.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753283Ab1BCEuy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 23:50:54 -0500
In-Reply-To: <1296697862.4434.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Feb 2011 02:51:02 +0100

> Le mercredi 02 f=E9vrier 2011 =E0 17:19 -0800, Stephen Hemminger a =E9=
crit :
>> The change to allow divisor to be a parameter (in 2.6.38-rc1)
>>  commit 817fb15dfd988d8dda916ee04fa506f0c466b9d6
>> introduced a possible deadlock caught by sparse.
>>=20
>> The scheduler tree lock was left locked in the case of an incorrect
>> divisor value. Simplest fix is to move test outside of lock
>> which also solves problem of partial update.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Oops, thanks Stephen !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
