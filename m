From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 21:42:03 +0100
Message-ID: <1354912923.9124.1.camel@jlt4.sipsolutions.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric@regit.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:58566 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424123Ab2LGUlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 15:41:46 -0500
In-Reply-To: <20121207.153134.25835204617509469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 15:31 -0500, David Miller wrote:
> From: Eric Leblond <eric@regit.org>
> Date: Fri,  7 Dec 2012 19:56:01 +0100
> 
> Wireless folks, please take a look.  The issue is that,
> under the circumstances listed below, we get SKBs in
> the AF_PACKET input path that are shared.
> 
> Given the logic present in ieee80211_deliver_skb() I think
> the mac80211 code doesn't expect this either.

Indeed, it would certainly not like this, I'll take a look.

Eric, what's the driver you're using? I'm wondering whether paged skbs
vs. all data in the header would make a difference, hence the question.

johannes
