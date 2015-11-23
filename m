From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/9] net: ipmr: always define
 mroute_reg_vif_num
Date: Mon, 23 Nov 2015 11:39:19 +0100
Message-ID: <5652ECD7.1000104@cumulusnetworks.com>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
 <1448117852-4254-3-git-send-email-razor@blackwall.org>
 <CAHA+R7Pra5DW8UNyPDQKK6Y=J8nz4LvNvmHcsP7pY+-U5NHCKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <cwang@twopensource.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36379 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbbKWKjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 05:39:22 -0500
Received: by wmww144 with SMTP id w144so90186855wmw.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 02:39:21 -0800 (PST)
In-Reply-To: <CAHA+R7Pra5DW8UNyPDQKK6Y=J8nz4LvNvmHcsP7pY+-U5NHCKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2015 06:23 AM, Cong Wang wrote:
> On Sat, Nov 21, 2015 at 6:57 AM, Nikolay Aleksandrov
> <razor@blackwall.org> wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> Before mroute_reg_vif_num was defined only if any of the CONFIG_PIMSM_
>> options were set, but that's not really necessary as the size of the
>> struct is the same in both cases (checked with pahole, both cases size
>> is 3256 bytes) and we can remove some unnecessary ifdefs to simplify the
>> code.
>>
> 
> Not sure if this really simplifies the code, since now
> mroute_reg_vif_num is hidden
> deeper after your patch and there are still some code under CONFIG_IP_PIMSM.
> 
CONFIG_IP_PIMSM is removed in the next patch, and it's not "hidden" anymore
than it was before.

> If you really care about it, how about introducing a helper function
> to set and get
> mrt->mroute_reg_vif_num?
> 
Patches are welcome, if you don't get to it then I will with the next
set.
