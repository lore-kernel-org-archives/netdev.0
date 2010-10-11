From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net dst: use a percpu_counter to track entries
Date: Mon, 11 Oct 2010 23:29:33 +0200
Message-ID: <1286832573.30423.93.camel@edumazet-laptop>
References: <1286555854.2959.605.camel@edumazet-laptop>
	 <20101011.130758.70192030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34383 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756291Ab0JKV3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 17:29:54 -0400
Received: by wwj40 with SMTP id 40so4229265wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 14:29:53 -0700 (PDT)
In-Reply-To: <20101011.130758.70192030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 13:07 -0700, David Miller a =C3=A9crit =
:

> When I first read the subject line for this patch, I was
> scared, because I thought you were using a percpu counter
> for dst entry refcounts :-)
>=20
> Anyways this is fine, applied, thanks!

I though about a crazy idea for loopback device (but not a percpu
counter for dst refcounts)

Add a cpu field somewhere so that each cpu manipulates a different dst.

Or maybe just never cache such dst, so that each tcp socket uses its ow=
n
dst.



