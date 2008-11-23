From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question about HFSC atm+man patches
Date: Sun, 23 Nov 2008 15:05:35 +0100
Message-ID: <4929632F.3050200@trash.net>
References: <49292F54.4020803@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michal Soltys <soltys@ziu.info>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <49292F54.4020803@ziu.info>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Soltys wrote:
> I'm thinking about writing few simple patches that would introduce layer
> 2 adaptation to HFSC. Generally - instead of preparing adjusted rate
> table like some of the other qdiscs do (tbf, htb, ...), hfsc could
> simply adjust packets' lengths in qdisc code (and there are just few 
> places where it's done) - as it's used for all time / curve related 
> computations later. So the whole thing should be, at least in theory, 
> pretty straightforward.
> 
> The tc's interface would of course remain the same - that is - linklayer
> and overhead options, consistently with other qdiscs.
> 
> Would such approach be valid and possibly accepted ?

We already support generic size adjustment for all qdiscs. I'm
not sure about the userspace interface though.

> Another thing I'd like to add is detailed tc-hfsc man page (and maybe
> add/update other ones - but that's for a bit later).

That would be great.
