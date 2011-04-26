From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/13] Swap-over-NBD without deadlocking
Date: Tue, 26 Apr 2011 16:23:05 +0200
Message-ID: <1303827785.20212.266.camel@twins>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
 Neil Brown <neilb@suse.de>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1303803414-5937-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-04-26 at 08:36 +0100, Mel Gorman wrote:
> Comments?

Last time I brought up the whole swap over network bits I was pointed
towards the generic skb recycling work:

  http://lwn.net/Articles/332037/

as a means to pre-allocate memory, and it was suggested to simply pin
the few route-cache entries required to route these packets and
dis-allow swap packets to be fragmented (these last two avoid lots of
funny allocation cases in the network stack).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
