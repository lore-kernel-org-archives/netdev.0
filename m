From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive
 connections
Date: Tue, 05 May 2015 14:02:52 -0700
Message-ID: <1430859772.14545.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150501202908.GC6113@akamai.com>
	 <1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150505.160535.1034497188259706110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150505.160535.1034497188259706110.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-05 at 16:05 -0400, David Miller wrote:

> Applied, but I think you should give maybe a little bit more thought
> into the behavior when a not-large-enough buffer is supplied by the
> user.
> 
> Since we're talking about things on the order of 60 bytes or so at
> most, it seems clear to me that signalling an error is probably the
> most advisable thing to do in this situation.
> 
> Maybe you could signal an error, yet write the actual length to
> "optlen".  That way the user can figure out how much they need.  Then
> they at least would have the option of retrying with a larger buffer.
Seems fine to me, I'll provide a patch implementing your suggestions.

Thanks.
