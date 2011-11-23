From: Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Tue, 22 Nov 2011 21:37:17 -0800
Message-ID: <20111123053717.GK3344@sequoia.sous-sol.org>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
	<1321878007.2291.12.camel@mojatatu>
	<CAEP_g=8puZh8hihoyoHTc4f6cBu4jiDJQ6tqk6suQxR=dchyjA@mail.gmail.com>
	<1322012755.2039.36.camel@mojatatu> <4ECC5AAB.8000605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ECC5AAB.8000605-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

* John Fastabend (john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org) wrote:
> He is pushing and popping entire tags off 802.1Q for now but
> you can easily imagine MPLS tags and all sorts of other things
> people will _need_.

Right, already doing some generic encap/decap for tunnelling.

> Do we want tc and likely the skbedit action to explode into a
> packet mangling tool? Would it make sense to plug into ebtables
> perhaps with a new family, NFPROTO_OPENFLOW or even on the
> existing NFPROTO_BRIDGE.

Of course, ovs is not limited to layer2 switching.

> Although doing it with classifiers and more actions would flush
> out that TODO in act_mirred, and get us an mq_ingress among
> other things.
