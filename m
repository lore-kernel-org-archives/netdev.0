From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCHv2 net-next 0/6] 6lowpan: uncompress of addresses fix
Date: Wed, 14 Aug 2013 15:23:48 +0400
Message-ID: <520B68C4.7030602@gmail.com>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:55436 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759580Ab3HNLXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 07:23:52 -0400
Received: by mail-lb0-f178.google.com with SMTP id z5so6604473lbh.23
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 04:23:51 -0700 (PDT)
In-Reply-To: <1376478108-3539-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2013 03:01 PM, Alexander Aring wrote:
> The current implementation to uncompress addresses in a 6lowpan header
> is completely broken.
>
> This patch series fixes the parsing of addresses in a 6lowpan header.
> It contains a major rewrite of the uncompress address function to parse
> the address in a correct way.
>

Could you please describe in a few words how have you tested the changes?

Small cosmetic hint: lowpan_raw_dump_inline() already has an argument to 
print debug message, so there is no need to add extra pr_debug calls 
before it to print static text.

Alex

> Changes since v2:
>   - Add tags for net-next
>   - Change commit msg in Patch 1/6 that this patch depends for the following
>     patches
>
> Alexander Aring (5):
>    6lowpan: init ipv6hdr buffer to zero
>    6lowpan: introduce lowpan_fetch_skb function
>    6lowpan: add function to uncompress multicast addr
>    6lowpan: lowpan_uncompress_addr with address_mode
>    6lowpan: handle context based source address
>
> David Hauweele (1):
>    6lowpan: Fix fragmentation with link-local compressed addresses
>
>   net/ieee802154/6lowpan.c | 284 +++++++++++++++++++++++++++++++----------------
>   net/ieee802154/6lowpan.h |  20 +++-
>   2 files changed, 203 insertions(+), 101 deletions(-)
>
