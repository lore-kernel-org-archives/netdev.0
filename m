From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Sun, 22 Apr 2012 17:06:58 -0400 (EDT)
Message-ID: <20120422.170658.1841749508208198136.davem@davemloft.net>
References: <61c89e02-c916-421e-b469-62b307853b1b@tahiti.vyatta.com>
	<1335110082.2132.22.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1335110082.2132.22.camel@mojatatu>
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

From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Date: Sun, 22 Apr 2012 11:54:42 -0400

> On Sun, 2012-04-22 at 08:22 -0700, Stephen Hemminger wrote:
> 
>> Therefore Simon's
>> proposed hook is the only way to support it. But exposing that
>> hook does allow for other misuse.
> 
> If you object to this, then you gotta object to the UDP equivalent 
> which has been around for sometime now for legitimate reasons
> and could be used by STT (I think the claim was no hardware
> does USO);->

I don't think so, for the UDP case it's much different.  All the
necessary "protocol" work has been performed on the packet by the time
the encap handler runs for UDP.

I'm not saying I still object to this TCP thing, however.
