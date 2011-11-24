From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
 components.
Date: Thu, 24 Nov 2011 08:25:02 -0500
Message-ID: <1322141102.1949.198.camel@mojatatu>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
	<1321878007.2291.12.camel@mojatatu>
	<CAEP_g=8puZh8hihoyoHTc4f6cBu4jiDJQ6tqk6suQxR=dchyjA@mail.gmail.com>
	<1322012755.2039.36.camel@mojatatu>
	<E521938A-E5E5-48CE-B784-6BF38ED274AE@nicira.com>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <E521938A-E5E5-48CE-B784-6BF38ED274AE-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Hi Justin,

I apologize, I did not intend to demean your work. There
are lots of clever ideas in there and you may have wanted
to put out something in a short period out there.

The most basic IMO is to use netlink if you are doing
it from a programmatic interface. You seem to be doing that
already for other items (eg HTB) in the setup. There are
a few libraries out there you could use but i realize
that they may not match your license requirements.
Maybe you could isolate your netlink code and make it 
standalone based on the license you use and people who 
need that could use it.

The other thing, is you match every flow on the specific
virtual port - this may be design intent but it appears
very inflexible.

cheers,
jamal

On Wed, 2011-11-23 at 18:34 -0800, Justin Pettit wrote:
> On Nov 22, 2011, at 5:45 PM, Jamal Hadi Salim wrote:
> 
> > BTW, you  _are using some of the actions_ already (the policer for
> > example to do rate control; no disrespect intended but in a terrible
> > way). 
> 
> Hi, Jamal.  I did the initial implementation of the rate control in Open vSwitch.  
> Can you help us out with a few more specifics on the problems you see and how they 
> could be improved?
> 
> Thanks,
> 
> --Justin
> 
> 
