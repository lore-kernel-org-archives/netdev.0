From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Mon, 19 Jan 2015 20:07:20 +0100
Message-ID: <1421694440.13047.1.camel@stressinduktion.org>
References: <1421456558-27144-1-git-send-email-harouth@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56736 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbbASTHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 14:07:23 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 42084206FF
	for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 14:07:22 -0500 (EST)
In-Reply-To: <1421456558-27144-1-git-send-email-harouth@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2015-01-16 at 18:02 -0700, Harout Hedeshian wrote:
> The kernel forcefully applies MTU values received in router
> advertisements provided the new MTU is less than the current. This
> behavior is undesirable when the user space is managing the MTU. Instead
> a sysctl flag 'accept_ra_mtu' is introduced such that the user space
> can control whether or not RA provided MTU updates should be applied. The
> default behavior is unchanged; user space must explicitly set this flag
> to 0 for RA MTUs to be ignored.
> 
> Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>

Makes sense!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
