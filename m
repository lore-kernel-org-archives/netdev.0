From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 19:35:36 +0200
Message-ID: <7iwsn8s107.fsf@lanthane.pps.jussieu.fr>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
	<873apwrc4t.fsf@basil.nowhere.org>
	<7i3apwbblk.fsf@lanthane.pps.jussieu.fr>
	<20080408163252.GS16647@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:61244 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755541AbYDHRfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 13:35:42 -0400
In-Reply-To: <20080408163252.GS16647@one.firstfloor.org> (Andi Kleen's message of "Tue\, 8 Apr 2008 18\:32\:52 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> no net_random/srandom32 is per CPU and likely does the wrong thing for you.

Why is that?  I'm only using this to initialise a global data
structure, why should it matter that I use per-cpu state?

                                        Juliusz
