From: Alan Ott <alan@signal11.us>
Subject: Re: [Linux-zigbee-devel] [PATCH] wpan: use GFP_ATOMIC instead of
 GFP_KERNEL
Date: Tue, 19 Feb 2013 15:31:58 -0800
Message-ID: <51240B6E.5000501@signal11.us>
References: <1360078474-24362-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55411 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933654Ab3BSXcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 18:32:00 -0500
In-Reply-To: <1360078474-24362-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2013 07:34 AM, Alexander Aring wrote:
> I got this message at runtime:
>
> [   48.847347] BUG: scheduling while atomic: swapper/0/0/0x40000100

Hi Alexander,

Please check out the patch set here:

      https://github.com/beagleboard/kernel/tree/3.8/patches/6lowpan

This is Tony's patch set which is not merged yet and might save you some 
time. Tony is hoping to get much of it merged this cycle.

Alan.
