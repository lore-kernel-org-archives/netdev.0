From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 16:13:13 -0400 (EDT)
Message-ID: <20120423.161313.1582195533832554777.davem@davemloft.net>
References: <20120423.151533.694306336485319759.davem@davemloft.net>
	<20120423121934.195e898c@nehalam.linuxnetplumber.net>
	<CAEP_g=_3om5aR=P0ffa9421KhvYYrMEeE33TNcCC9UV6+XVWAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=_3om5aR=P0ffa9421KhvYYrMEeE33TNcCC9UV6+XVWAQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Date: Mon, 23 Apr 2012 13:08:49 -0700

> Assuming that the TCP stack generates large TSO frames on transmit
> (which could be the local stack; something sent by a VM; or packets
> received, coalesced by GRO and then encapsulated by STT) then you can
> just prepend the STT header (possibly slightly adjusting things like
> requested MSS, number of segments, etc. slightly).  After that it's
> possible to just output the resulting frame through the IP stack like
> all tunnels do today.

Which seems to potentially suggest a stronger intergration of the STT
tunnel transmit path into our IP stack rather than the approach Simon
is taking
