From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 30 Nov 2011 08:23:05 -0500
Message-ID: <1322659385.2243.23.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<CAEP_g=-+F8bpkb8Qe1bPk65PQVNxz+VO7NoUrBCw6=GDUFbOFg@mail.gmail.com>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=-+F8bpkb8Qe1bPk65PQVNxz+VO7NoUrBCw6=GDUFbOFg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Tue, 2011-11-29 at 22:18 -0800, Jesse Gross wrote:
>  As Jamal alluded to above, it's
> actually the bridge code which is more conceptually similar. 

Either you misread what i said or i miscommunicated.
The exact similarity is in classifier action in the datapath.
The bridge, as i suggested, could have had at least two features
added to it in regards to learning to achieve what you wanted it to.
But as pointed out the bridge - which is a victim of combining policy
and mechanism in one spot - already has too many features. If we cleanly
separate out those things, then i dont see why we need two bridge
implementations.

Ok, so here's a digression:
I am uncomfortable with the fact i have to use ovs as the way to
configure things in a 48 port Gige switch. In Linux we have netdevs;
if you expose things as netdevs, for starters i can use standard
tools to do things to them. But this is a side discussion I started
with Justin - so you may have no pony in this race.


cheers,
jamal
