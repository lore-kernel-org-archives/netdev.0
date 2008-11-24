From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 02/10] tcp: move tcp_simple_retransmit to tcp_input
Date: Mon, 24 Nov 2008 18:58:25 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811241844490.30728@wrl-59.cs.helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <87skphqdx7.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1455546864-1227545905=:30728"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60578 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbYKXQ61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:58:27 -0500
In-Reply-To: <87skphqdx7.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1455546864-1227545905=:30728
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 24 Nov 2008, Andi Kleen wrote:

> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> writes:
> 
> tcp: move tcp_simple_retransmit to tcp_input
> 
> Why? It seems like a clear output function.

What makes you think so? It's as much output as e.g., tcp_enter_loss
(or in fact less than that since enter_loss is triggered mainly by rto)?

Besides, it's action based on input, the name is just misnower as it 
retransmit nothing except calling tcp_xmit_retransmit_queue. Every state 
change it does is similar to what is being done elsewhere in 
the tcp_input.c (I won't waste my time on listing them here :-)).

Not that it's that extremely big deal but doing some wq processing 
related changes have forced me to go into that other file just because
of that particular function.

-- 
 i.
---696208474-1455546864-1227545905=:30728--
