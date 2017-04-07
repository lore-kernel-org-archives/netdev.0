From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 7 Apr 2017 21:06:01 +0200
Message-ID: <20170407190601.GA22991@salvia>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
 <20170407.115315.23470877439489670.davem@davemloft.net>
 <1491591552.5800.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1491591552.5800.1.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 07, 2017 at 08:59:12PM +0200, Johannes Berg wrote:
[...]
> Heh. I think I really want to solve - at least partially - nla_parse()
> to see that it can be done this way. It'd be nice to even transform all
> the callers (I generated half of these patches with spatch anyway) to
> have at least that.

We can just have a modified version of nla_parse that deals with this.
We can probably use struct nla_policy to place the extended error code
or the string (as we discussed I don't need string errors, but I'm
fine if other people find it useful).

Thanks!
