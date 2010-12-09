From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc: show format ABI changed
Date: Thu, 09 Dec 2010 02:18:14 +0100
Message-ID: <1291857494.2795.1.camel@edumazet-laptop>
References: <20101208145136.1ca3ece4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39681 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583Ab0LIBSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 20:18:18 -0500
Received: by wyb28 with SMTP id 28so1730705wyb.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 17:18:17 -0800 (PST)
In-Reply-To: <20101208145136.1ca3ece4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 14:51 -0800, Stephen Hemminger=
 a =C3=A9crit :
> Although well intentioned, the following patch should have not
> been applied since it changes the kernel ABI. It broke some scripts
> parsing the output format of tc commands.
>=20
> Before HTB would report bogus zero values, now it reports
> nothing and that changes the output format.  Like the empty
> fields in /proc, I argue we can't play fast and loose with
> netlink responses.
>=20
> Not a big deal to fix the script in this case, in this case
> so don't revert it.

Thanks.

I really prefer not giving false information to user.

If you change tc, please add an option so that user can ask tc not
invent "zero values"



