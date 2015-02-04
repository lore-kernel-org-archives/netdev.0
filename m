From: Jouni Malinen <jouni@codeaurora.org>
Subject: Re: [PATCH] bridge: Remove BR_PROXYARP flooding check code
Date: Wed, 4 Feb 2015 19:36:14 +0200
Message-ID: <20150204173614.GA17251@jouni.qca.qualcomm.com>
References: <1418052460-30691-1-git-send-email-jouni@codeaurora.org>
 <20141209142158.7e513dbf@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kyeyoon Park <kyeyoonp@codeaurora.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:42423 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966519AbbBDRgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 12:36:21 -0500
Content-Disposition: inline
In-Reply-To: <20141209142158.7e513dbf@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2014 at 02:21:58PM -0800, Stephen Hemminger wrote:
> On Mon,  8 Dec 2014 17:27:40 +0200
> > From: Kyeyoon Park <kyeyoonp@codeaurora.org>
> > Because dropping broadcast packets for IEEE 802.11 Proxy ARP is more
> > selective than previously thought, it is better to remove the direct
> > dropping logic in the bridge code in favor of using the netfilter
> > infrastructure to provide more control on which frames get dropped. This
> > code was added in commit 958501163ddd ("bridge: Add support for IEEE
> > 802.11 Proxy ARP").

> Aren't you at risk of duplicate ARP responses in some cases.
> You can't assume user will run netfilter.

The 'bridge: Selectively prevent bridge port flooding for proxy ARP'
patch that I posted earlier today addresses this by keeping record of
whether the proxyarp functionality has replied to a packet and skipping
flooding conditionally on that. In other words, this 'bridge: Remove
BR_PROXYARP flooding check code' can be dropped.

-- 
Jouni Malinen                                            PGP id EFC895FA
