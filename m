From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Wed, 12 Apr 2017 11:19:13 -0400 (EDT)
Message-ID: <20170412.111913.497795978751789475.davem@davemloft.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
        <1492007254.2855.10.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1492007254.2855.10.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 12 Apr 2017 16:27:34 +0200

> This works. An example BPF program is here:
> https://p.sipsolutions.net/ca32264f2b705e5e.txt
 ...
> One thing I'm not so sure about is the usage of __sk_buff.
 ...
> Instead it may make more sense to just have a "wifi_info(skb, info)"
> function you can call, e.g. with a structure that has various fields
> and flags to see which you care about.

I would advise against this, let the parsing part use __sk_buff and
therefore have maximum flexibility.  You really cannot predict the
future, so in my opinion it might be unwise to constrain at this point.
