From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH] mrf24j40: fix security-enabled processing on inbound
 frames
Date: Mon, 29 Feb 2016 14:49:22 -0500
Message-ID: <56D4A0C2.5090605@signal11.us>
References: <56C60EBA.2070707@zopieux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: zopieux <web@zopieux.com>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:45271 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753945AbcB2TtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 14:49:24 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 0DE2720A09
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:49:23 -0500 (EST)
In-Reply-To: <56C60EBA.2070707@zopieux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2016 01:34 PM, zopieux wrote:
> Fix the MRF24J40 handling of security-enabled frames so it does not
> block upon receiving such frames.
>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> Reported-by: Alexandre Macabies <web+oss@zopieux.com>
> Tested-by: Alexandre Macabies <web+oss@zopieux.com>
> ---
> When receiving a security-enabled IEEE 802.15.4 frame, the MRF24J40
> triggers a SECIF interrupt that needs to be handled for RX processing
> to keep functioning properly.
>
> This patch enables the SECIF interrupt and makes the MRF ignores all
> hardware processing of security-enabled frames, that is handled by the
> ieee802154 stack instead.
> ---

The "From" field of the email needs to have your real name in it. This 
will be where the "Author" field in git comes from.

It looks like there are a few separate things happening in this patch. 
Maybe they should be broken out in to separate patches. I see:

1. The ieee802154.h part,
2. The TX part,
3. The RX part.

The patch description only really describes the RX part.

Other than that, the actual code seems OK to me.

Alan.
