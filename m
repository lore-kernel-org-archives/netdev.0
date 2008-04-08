From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 17:28:48 +0200
Message-ID: <7i7if8bc27.fsf@lanthane.pps.jussieu.fr>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr> <47FAB688.7010807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:58739 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbYDHP4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 11:56:37 -0400
In-Reply-To: <47FAB688.7010807@trash.net> (Patrick McHardy's message of "Tue\, 08 Apr 2008 02\:04\:24 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I experienced with SFB myself some time ago and recall
> getting huge unfairness towards non-ECN connections.

I've only done informal checking, but didn't test ECN against non-ECN.
Will do, and I'll let you know the results.

> I just found my old tree and it was just Blue, which might explain this

Blue is supposed to be roughly fair w.r.t. TCP-compliant flows with
similar RTT.  If you see long-term unfairness with Blue at a single
RTT, then something is wrong at the sender.  I'll see if I can repeat
your issues.

Earlier versions of Linux did not reduce their sending rate when they
received ECE and the congestion window was just 1 MSS.  I don't know
if this bug has been fixed.

                                        Juliusz
