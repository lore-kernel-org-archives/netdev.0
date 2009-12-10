From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 19:53:58 +0100 (CET)
Message-ID: <alpine.LSU.2.01.0912101953360.23791@obet.zrqbmnf.qr>
References: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com> <4B207840.7080603@gmail.com> <97949e3e0912100950u51f627c9r515d9b69a02430f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:56951 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761405AbZLJSxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 13:53:55 -0500
In-Reply-To: <97949e3e0912100950u51f627c9r515d9b69a02430f4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Donnerstag 2009-12-10 18:50, Laurent Chavey wrote:
>
>good point.  I  agree with the need for the exception, I would just
>like it to be more explicit in the code itself (like a turn off
>check around that particular statement) so we do not have to scrub
>thru the compiler output to filter out good / bad warning. question:
>  why do we not force the timestamp in the skb before going thru the
>chain ?

Because it is probably too expensive to do, unless you employ
things like xt_time?
