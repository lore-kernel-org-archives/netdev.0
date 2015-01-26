From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Mon, 26 Jan 2015 17:19:25 +0100
Message-ID: <1422289165.2687.34.camel@stressinduktion.org>
References: <1421773565-5181-1-git-send-email-harouth@codeaurora.org>
	 <20150124.231432.1788575004982971514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: harouth@codeaurora.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49671 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752588AbbAZQTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 11:19:30 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id ABD58201E9
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 11:19:27 -0500 (EST)
In-Reply-To: <20150124.231432.1788575004982971514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sa, 2015-01-24 at 23:14 -0800, David Miller wrote:
> From: Harout Hedeshian <harouth@codeaurora.org>
> Date: Tue, 20 Jan 2015 10:06:05 -0700
> 
> > The kernel forcefully applies MTU values received in router
> > advertisements provided the new MTU is less than the current. This
> > behavior is undesirable when the user space is managing the MTU. Instead
> > a sysctl flag 'accept_ra_mtu' is introduced such that the user space
> > can control whether or not RA provided MTU updates should be applied. The
> > default behavior is unchanged; user space must explicitly set this flag
> > to 0 for RA MTUs to be ignored.
> > 
> > Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>
> 
> Under what circumstances would userland ignore a router advertized
> MTU, and are the RFCs ok with this?

Sometimes those advertised MTUs are used to perform DoS attacks /
performance-degrading attacks (force generation of fragments e.g.) on
hosts. In larger, maybe non-controlled networks, it would be desirable
if one could disable acceptance of the MTU option.

Of course, there are similar issues with other options in RAs, too, but
mostly they result in more catastrophic connection failures. ;)

Bye,
Hannes
