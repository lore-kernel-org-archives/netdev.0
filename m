From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
Date: Tue, 15 May 2012 14:30:09 -0400 (EDT)
Message-ID: <20120515.143009.2103212327515966852.davem@davemloft.net>
References: <1337106094.15553.5.camel@jlt3.sipsolutions.net>
	<20120515.142405.633851408201128056.davem@davemloft.net>
	<1337106548.15553.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337106548.15553.8.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
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

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 15 May 2012 20:29:08 +0200

> On Tue, 2012-05-15 at 14:24 -0400, David Miller wrote:
> 
>> > But don't you have to do something in the sources to actually get
>> > dynamic_debug enabled? I'm concerned this will make mac80211 debugging
>> > inconsistent - the normal bits are just printk() still, and the
>> > rate-limited bits need some special enabling? That seems odd.
>> 
>> You can turn them all off or on with a simple flip of a boolean switch
>> at run-time.  Or, alternatively, you can turn them on or off in a
>> finer grained manner with other run-time facilities.
>> 
>> There should be a transition away from explicit KERN_DEBUG.
> 
> I support that, but I think it's confusing to have things mixed. Also,
> we seem to have printk_ratelimit(), so I'd prefer to have that used in
> mac80211 instead until everything there moves over to newer facilities.

No, you don't want that, it's different from the networking ratelimit
mechanism.  Joe explained this, and I just explaing it to you once
again in another reply.
