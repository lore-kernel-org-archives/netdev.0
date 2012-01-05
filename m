From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in netem reordering
Date: Thu, 05 Jan 2012 06:34:16 +0100
Message-ID: <1325741656.2634.20.camel@edumazet-laptop>
References: <CAGK4HS8YBBwPtPpQhi8gas=RBE6wao6KZ1dwbwo2rxn4qXggCQ@mail.gmail.com>
	 <1325734526-13428-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:32841 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab2AEFeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 00:34:21 -0500
Received: by werm1 with SMTP id m1so110173wer.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 21:34:20 -0800 (PST)
In-Reply-To: <1325734526-13428-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 04:35 +0100, Hagen Paul Pfeifer a =C3=A9=
crit :
> Not now, but it looks you are correct. q->qdisc is NULL until another
> additional qdisc is attached (beside tfifo). See 50612537e9ab2969312.
> The following patch should work.
>=20
> From: Hagen Paul Pfeifer <hagen@jauu.net>
>=20
> netem: catch NULL pointer by updating the real qdisc statistic
>=20
> Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---

Thanks for this fix !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
