From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH] mrf24j40: fix security-enabled processing on inbound
 frames
Date: Mon, 29 Feb 2016 13:46:37 -0500
Message-ID: <56D4920D.7050306@signal11.us>
References: <56C60EBA.2070707@zopieux.com> <56CC265C.2040906@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>,
	zopieux <web@zopieux.com>
To: Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44853 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056AbcB2Sqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 13:46:38 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id CD02E20A06
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:46:37 -0500 (EST)
In-Reply-To: <56CC265C.2040906@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 04:29 AM, Alexander Aring wrote:
> Alan, do you have some comments about that?
>
> Currently the mrf24j40 goes into a deadlock if a frame with security
> enable bit is set. As you see, I helped myself to create this patch and solve
> this stupid default behaviour of mrf24j40. :-)
>

Hi Alex, I'll look at this today.

Alan.
