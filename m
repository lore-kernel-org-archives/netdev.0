From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Fri, 23 Sep 2011 22:17:42 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1109232215420.10441@melkinpaasi.cs.helsinki.fi>
References: <1316757739.2560.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-129742481-1316805463=:10441"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42353 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab1IWTRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 15:17:44 -0400
In-Reply-To: <1316757739.2560.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-129742481-1316805463=:10441
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Fri, 23 Sep 2011, Eric Dumazet wrote:

> While playing with a new ADSL box at home, I discovered that ECN
> blackhole can trigger suboptimal quickack mode on linux : We send one
> ACK for each incoming data frame, without any delay and eventual
> piggyback.
> 
> This is because TCP_ECN_check_ce() considers that if no ECT is seen on a
> segment, this is because this segment was a retransmit.
> 
> Refine this heuristic and apply it only if we seen ECT in a previous
> segment, to detect ECN blackhole at IP level.

This seems sensible thing to do.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>


-- 
 i.
--8323329-129742481-1316805463=:10441--
