From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] forcedeath: Fix bql support for forcedeath
Date: Fri, 02 Dec 2011 11:46:43 +0100
Message-ID: <1322822803.2607.2.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322819300-14330-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62919 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406Ab1LBKqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 05:46:47 -0500
Received: by vbbfc26 with SMTP id fc26so2172775vbb.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 02:46:46 -0800 (PST)
In-Reply-To: <1322819300-14330-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 10:48 +0100, igorm@etf.rs a =C3=
=A9crit :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Moved netdev_completed_queue() out of while loop in function nv_tx_do=
ne_optimized().
> Because this function was in while loop,
> BUG_ON(count > dql->num_queued - dql->num_completed)
> was hit in dql_completed().
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
