From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] net: fix netdev features shift for features bit > 31
Date: Sun, 21 Apr 2013 22:43:19 +0200
Message-ID: <f7afa813-42a7-4c3f-9059-52afaac4088b@email.android.com>
References: <1366538974-4589-1-git-send-email-kaber@trash.net> <1366538974-4589-2-git-send-email-kaber@trash.net> <20130421.155056.1845781789394372451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50685 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab3DUU7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 16:59:24 -0400
In-Reply-To: <20130421.155056.1845781789394372451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller <davem@davemloft.net> schrieb:

>From: Patrick McHardy <kaber@trash.net>
>Date: Sun, 21 Apr 2013 12:09:33 +0200
>
>>    drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c: In function
>'qlcnic_set_netdev_features':
>>>> drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:967:7: warning:
>large integer implicitly truncated to unsigned type [-Woverflow]
>> 
>> This should be fixed by explicitly using 1ULL for the shifted value.
>> 
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>
>The limitation is in the variable being assigned to, not the value
>itself.
>
>The "1" is already cast to a netdev_features_t by the macro
>definition.

Right, I thought the warning was caused by the shift not being able to represent the result. I'll fix it up properly later.
