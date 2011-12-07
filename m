From: Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>
Subject: Re: Time in Queue, bufferbloat,
	and... our accidentally  interplanetary network
Date: Wed, 07 Dec 2011 11:15:38 +0100
Message-ID: <9dfc3c5eb811f2774b378fce0158b3e7@localhost>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	<1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
In-Reply-To: <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
List-Unsubscribe: <https://lists.bufferbloat.net/options/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/bloat>
List-Post: <mailto:bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
List-Help: <mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=subscribe>
Sender: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
Errors-To: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
List-Id: netdev.vger.kernel.org


On Mon, 05 Dec 2011 11:59:34 +0100, Eric Dumazet wrote:


> Adding a time limit is possible, all we need is a proper design and
> implementation :)
> 
> Here is my suggestion :
> 
> Design a new tfifo/tred qdisc, with following properties :
> 
> Adaptative RED, (ECN enabled + head drop), but instead of using
> bytes/packet qlen average, use time_in_queue average.

Question one: is anything wrong with sfb or choke as the basis, instead of
RED?

Question two: I submitted pfast_head_drop to drop more outdated data
instead of new data. Back in time I thought TCP _may_ experience benefits
because more up-to-date SACK data packets are saved. Are there any other
TCP advantages with head drop policy?

Hagen
