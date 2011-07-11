From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Mon, 11 Jul 2011 08:27:55 -0700
Message-ID: <20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
	<CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	David Lamparter <equinox@diac24.net>, davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38379 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757833Ab1GKP2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 11:28:48 -0400
In-Reply-To: <CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Jul 2011 17:04:30 +0100
Nick Carter <ncarter100@gmail.com> wrote:

> Updated diffs so they apply to net-next (Original diffs were based off 2.6.38).
> 
> Any chance of getting these diffs applied?  The default behaviour of
> the bridge code is unchanged.  They solve the problem of
> authenticating a virtual 802.1x supplicant machine against an external
> 802.1X authenticator.  It is also a general solution that allows the
> forwarding of any combination of the IEEE 802 local multicast groups.
> 
> Signed-off-by: Nick Carter <ncarter100@gmail.com>
> Reviewed-by: David Lamparter <equinox@diac24.net>

I am still undecided on this. Understand the need, but don't like idea
of bridge behaving in non-conforming manner. Will see if IEEE 802 committee
has any input.

Also, don't want to build more knobs in with sysfs that are per-bridge.
Eventually, the plan is to make all the setting per-port with sysctl's
like IPv6.
