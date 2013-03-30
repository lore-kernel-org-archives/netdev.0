From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next] net: squash ->rx_handler and
 ->rx_handler_data into single rcu pointer
Date: Sat, 30 Mar 2013 12:31:03 -0700
Message-ID: <1364671863.5113.122.camel@edumazet-glaptop>
References: <1364659034-7049-1-git-send-email-jiri@resnulli.us>
	<1364660588.5113.110.camel@edumazet-glaptop>
	<20130330171325.GC1544@minipsycho.orion>
	<1364671688.5113.119.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, paulmck-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	streeter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nicolas.2p.debian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1364671688.5113.119.camel@edumazet-glaptop>
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

On Sat, 2013-03-30 at 12:28 -0700, Eric Dumazet wrote:
> On Sat, 2013-03-30 at 18:13 +0100, Jiri Pirko wrote:
> 
> > Well, not entirely true, depends on arch.
> > 
> 
> Are you really trying to obfuscate stack because of Alpha architecture ?


By the way, only dev->rx_handler needs to be RCU protected.

The patch send yesterday make the second rcu_dereference() (to get
rx_handler_data) totally irrelevant.
