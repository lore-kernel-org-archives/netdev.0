From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 bluetooth-next 04/10] ndisc: add addr_len parameter to
 ndisc_opt_addr_space
Date: Mon, 2 May 2016 21:37:14 +0200
Message-ID: <109698cb-18ae-abdb-34a5-1db5a2e8dc6b@stressinduktion.org>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-5-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:55614 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754491AbcEBThT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 15:37:19 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 92D9020993
	for <netdev@vger.kernel.org>; Mon,  2 May 2016 15:37:18 -0400 (EDT)
In-Reply-To: <1461140382-4784-5-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.04.2016 10:19, Alexander Aring wrote:
> This patch makes the address length as argument for the
> ndisc_opt_addr_space function. This is necessary to handle addresses
> which don't use dev->addr_len as address length.

Would it make sense for patch 4, 5 and 6 to add the operation to ndisc_ops?

Thanks,
Hannes
