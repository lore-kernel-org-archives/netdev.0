From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
 online CPUs default
Date: Tue, 23 Mar 2010 08:27:30 +0100
Message-ID: <1269329250.3043.19.camel@edumazet-laptop>
References: <4BA85EA2.1090304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62612 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab0CWH1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 03:27:38 -0400
Received: by vws6 with SMTP id 6so716561vws.19
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 00:27:36 -0700 (PDT)
In-Reply-To: <4BA85EA2.1090304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 14:24 +0800, Changli Gao a =C3=A9crit :
> make distributing packets fairly among all the online CPUs default.
>=20
> Make distributing packets fairly among all the online CPUs default, t=
hen
> users don't need any explicit configuration to get the benefit of RPS=
=2E
>=20

Some people want to dedicate a cpu to network interrupts, cache hits
only, to get low latencies.
RPS is not a win for all workloads.

I think we should not change default without a knob.

Didnt we discussed all this during last months ?


