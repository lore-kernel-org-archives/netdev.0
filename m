From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Mon, 21 Nov 2011 07:20:07 -0500
Message-ID: <1321878007.2291.12.camel@mojatatu>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321657938-21761-5-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

On Fri, 2011-11-18 at 15:12 -0800, Jesse Gross wrote:
> Open vSwitch is a multilayer Ethernet switch targeted at virtualized
> environments.  In addition to supporting a variety of features
> expected in a traditional hardware switch, it enables fine-grained
> programmatic extension and flow-based control of the network.
> This control is useful in a wide variety of applications but is
> particularly important in multi-server virtualization deployments,
> which are often characterized by highly dynamic endpoints and the need
> to maintain logical abstractions for multiple tenants.
> 
> The Open vSwitch datapath provides an in-kernel fast path for packet
> forwarding.  It is complemented by a userspace daemon, ovs-vswitchd,
> which is able to accept configuration from a variety of sources and
> translate it into packet processing rules.
> 

So the last time we had a discussion on this on the list, we seemed
to agree that you could use the tc classifier-action infrastructure.
For simplicity, we agreed you will need to do a speacilized classifier.
You may need to add a few more actions. What happened since?

You are replicating a lot of code and semantic that exist (not just on
classifier actions). You could improve the exisiting infrastructure
instead. We are eventually going to have two competing interfaces as 
a result. You may only need 1 or 2 different classification schemes
today and try to justify you need it for simplicity - but in a few
months you'll need one more then another action and another and 
you'll keep adding to your infrastructure.

cheers,
jamal
