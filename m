From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in
 absence of MSS option
Date: Mon, 10 Jun 2013 03:19:54 -0400
Message-ID: <20130610071954.GA13500@gmail.com>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
 <1370880461-4265-4-git-send-email-pablo@netfilter.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 11, 2013 at 09:43:07AM +0100, David Laight wrote:
> Is setting the mss to 536 actually ever sensible?
> RFC 879 might say that it is the default (and the minimum
> that must be supported), but in practise the actual mss
> is very likely to be only slightly shorter than the standard
> ethernet mss.
> Although strict conformance with RFC 879 might require the mss
> be clamped to 536, pragmatically a value much nearer 1400 would
> make sense - systems with very low mtu/mss are probably likely
> to advertise it.

Read the associated bugzilla - there was at least one real world
example where setting a higher MSS was causing breakage.

Phil

https://bugzilla.netfilter.org/show_bug.cgi?id=662
