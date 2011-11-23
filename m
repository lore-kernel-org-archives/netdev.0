From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 23 Nov 2011 07:47:43 -0500
Message-ID: <1322052463.2039.135.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322035942.1298.56.camel@edumazet-laptop>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322035942.1298.56.camel@edumazet-laptop>
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

On Wed, 2011-11-23 at 09:12 +0100, Eric Dumazet wrote:

> I had no time to look at OVS, but current tc model is not scalable,
> everything is performed under a queue lock.
> Maybe its time to redesign a new model, based on modern techniques.

Making the enqueur/dequeuer lockless would be a big win. What happened
to your idea of ring buffer?
What other hot areas do you see? It used to be ingress/egress share
the qdisc lock - but that is now gone.

> By the way, we seriously lack good documentation on tc, not counting
> many features. Code might be there, but without documenation, working
> samples, who can use it ?
> 
> Take a look at last cls_flow extension, and try to use it on a real
> setup, you'll find its almost not possible...


There's no tc-central.org unlike the nice effort the netfilter guys have
put over the years. Documentation is there - sometimes a little too much
with differing "opinions" (lartc that Herbert pointed to is a good
starting point); but googling also helps. 
Unfortunately, sometimes the people who understand stuff have no
motivation to do docs.

cheers,
jamal
