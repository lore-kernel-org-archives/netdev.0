From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Sun, 22 Apr 2012 11:54:42 -0400
Message-ID: <1335110082.2132.22.camel@mojatatu>
References: <61c89e02-c916-421e-b469-62b307853b1b@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, eric dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <61c89e02-c916-421e-b469-62b307853b1b-bX68f012229Xuxj3zoTs5AC/G2K4zDHf@public.gmane.org>
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

On Sun, 2012-04-22 at 08:22 -0700, Stephen Hemminger wrote:

> STT isn't really doing TCP, it just lying and pretending to be
> TCP to allow TSO to work! There is no packet ordering, sequence
> numbers or any real transport layer. 

True. It is a nice engineering hack but even as a protocol enhancement
questionable at best.

> Therefore Simon's
> proposed hook is the only way to support it. But exposing that
> hook does allow for other misuse.

If you object to this, then you gotta object to the UDP equivalent 
which has been around for sometime now for legitimate reasons
and could be used by STT (I think the claim was no hardware
does USO);->

cheers,
jamal
