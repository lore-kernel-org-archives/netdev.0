From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH] mrf24j40: fix security-enabled processing on inbound
 frames
Date: Thu, 10 Mar 2016 17:40:47 +0100
Message-ID: <56E1A38F.6050108@osg.samsung.com>
References: <56C60EBA.2070707@zopieux.com> <56D4A0C2.5090605@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: Alan Ott <alan@signal11.us>, zopieux <web@zopieux.com>,
	linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:44625 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221AbcCJQkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 11:40:51 -0500
In-Reply-To: <56D4A0C2.5090605@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 29/02/16 20:49, Alan Ott wrote:
> On 02/18/2016 01:34 PM, zopieux wrote:
>> Fix the MRF24J40 handling of security-enabled frames so it does not
>> block upon receiving such frames.
>>
>> Signed-off-by: Alexander Aring <aar@pengutronix.de>
>> Reported-by: Alexandre Macabies <web+oss@zopieux.com>
>> Tested-by: Alexandre Macabies <web+oss@zopieux.com>
>> ---
>> When receiving a security-enabled IEEE 802.15.4 frame, the MRF24J40
>> triggers a SECIF interrupt that needs to be handled for RX processing
>> to keep functioning properly.
>>
>> This patch enables the SECIF interrupt and makes the MRF ignores all
>> hardware processing of security-enabled frames, that is handled by the
>> ieee802154 stack instead.
>> ---
>
> The "From" field of the email needs to have your real name in it. This 
> will be where the "Author" field in git comes from.
>
> It looks like there are a few separate things happening in this patch. 
> Maybe they should be broken out in to separate patches. I see:
>
> 1. The ieee802154.h part,
> 2. The TX part,
> 3. The RX part.
>
> The patch description only really describes the RX part.
>

zopieux, could you split the patch as Alan suggested and re-submitted 
the series?

regards
Stefan Schmidt
