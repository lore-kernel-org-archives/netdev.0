From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] net: introduce skb_flow_dissect()
Date: Mon, 28 Nov 2011 19:06:04 -0500 (EST)
Message-ID: <20111128.190604.1713178066845491526.davem@davemloft.net>
References: <1322493738.2292.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4ED3B603.4010702@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, dan-BZ4SNL/Vixll57MIdRCFDg@public.gmane.org
To: dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <4ED3B603.4010702-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
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

From: Dimitris Michailidis <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Mon, 28 Nov 2011 08:25:39 -0800

>> +bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys
>> *flow)
>> +{
>> +	int poff, nhoff = skb_network_offset(skb);
>> +	u8 ip_proto;
>> +	u16 proto = skb->protocol;
> 
> __be16 instead of u16 for proto?

I'll take care of this when I apply these patches.
