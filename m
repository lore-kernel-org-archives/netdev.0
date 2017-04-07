From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 7 Apr 2017 21:45:57 +0200
Message-ID: <20170407194557.GA23613@salvia>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
 <20170407.115315.23470877439489670.davem@davemloft.net>
 <1491591552.5800.1.camel@sipsolutions.net>
 <20170407190601.GA22991@salvia>
 <1491592185.5800.7.camel@sipsolutions.net>
 <20170407192134.GA23205@salvia>
 <1491593357.5800.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1491593357.5800.13.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 07, 2017 at 09:29:17PM +0200, Johannes Berg wrote:
> On Fri, 2017-04-07 at 21:21 +0200, Pablo Neira Ayuso wrote:
> > I think the most flexible way is to pass the container error
> > structure to nla_parse() so it sets this for you. This would also
> > save tons of "malformed attribute" strings.
> 
> Yes, for sure. The thing is we'll probalby have to pass down the
> request skb *and* the error struct so that we can get the offset, and
> this seems like the generic thing that we really should try to get the
> most information generated.

We only need to store the pointer to the attribute in the error
container structure. We can calculate the offset from nl_err() by
pasing the skbuff as parameter there, right?
