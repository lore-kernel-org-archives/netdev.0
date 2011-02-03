From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sfq: deadlock in error path
Date: Thu, 03 Feb 2011 02:51:02 +0100
Message-ID: <1296697862.4434.1.camel@edumazet-laptop>
References: <20110202171951.09b89d92@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36973 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1BCBvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 20:51:10 -0500
Received: by wwa36 with SMTP id 36so698395wwa.1
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 17:51:09 -0800 (PST)
In-Reply-To: <20110202171951.09b89d92@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 17:19 -0800, Stephen Hemminger =
a =C3=A9crit :
> The change to allow divisor to be a parameter (in 2.6.38-rc1)
>  commit 817fb15dfd988d8dda916ee04fa506f0c466b9d6
> introduced a possible deadlock caught by sparse.
>=20
> The scheduler tree lock was left locked in the case of an incorrect
> divisor value. Simplest fix is to move test outside of lock
> which also solves problem of partial update.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Oops, thanks Stephen !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

But please, please, please, please, please, remove dada1@cosmosbay.com,
as this address is no longer usable for me !



