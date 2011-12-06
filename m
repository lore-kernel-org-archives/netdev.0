From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix compile errors if CONFIG_CNIC is
 not set
Date: Tue, 06 Dec 2011 16:43:17 -0500 (EST)
Message-ID: <20111206.164317.1552410915949798281.davem@davemloft.net>
References: <1323205088-29693-1-git-send-email-mchan@broadcom.com>
	<1323205383.2690.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mchan@broadcom.com, netdev@vger.kernel.org, barak@broadcom.com,
	eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066Ab1LFVnV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:43:21 -0500
In-Reply-To: <1323205383.2690.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Dec 2011 22:03:03 +0100

> Le mardi 06 d=E9cembre 2011 =E0 12:58 -0800, Michael Chan a =E9crit :
>> Don't provide FCoE and iSCSI statistics to management firmware if
>> CONFIG_CNIC is not set.  Some needed structure fields are not define=
d
>> without CONFIG_CNIC.
>>=20
>> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>=20
>=20
> Thanks for the fast answer, and yes, no more build error :)

Applied, thanks.
