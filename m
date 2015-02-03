From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [V2,for,3.19,3/7] rtlwifi: rtl8192ee: Fix adhoc fail
Date: Tue, 03 Feb 2015 15:23:50 +0200
Message-ID: <87r3u7w2l5.fsf@kamboji.qca.qualcomm.com>
References: <20150203131516.799471409D0@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:34520 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965339AbbBCNZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 08:25:24 -0500
In-Reply-To: <20150203131516.799471409D0@smtp.codeaurora.org> (Kalle Valo's
	message of "Tue, 3 Feb 2015 13:15:16 +0000 (UTC)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kalle Valo <kvalo@codeaurora.org> writes:

>> From: Troy Tan <troy_tan@realsil.com.cn>
>> 
>> When the buffer descriptor index exceeds 2, then a TX HANG condition
>> will result.
>> 
>> Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> Cc: Stable <stable@vger.kernel.org> [V3.18]
>
> Thanks, 4 patches applied to wireless-drivers-next.git:
>
> b661a5da5776 rtlwifi: rtl8192ee: Fix adhoc fail
> 6e5f44361628 rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write point
> 92ff754240b8 rtlwifi: rtl8192ee: Fix parsing of received packet
> 21b39ddb5bb2 rtlwifi: rtl8192ee: Fix DMA stalls
>
> 3 patches skipped:

I had to skip these three patches because of my mistake. So what I did
was that I had merged ("fast forwarded") the net tree into my
wireless-drivers tree and not realising I should not do that. So now I
can't merge wireless-drivers into wireless-drivers-next anymore, as it
will pull unnecessary net changes.

> [V2,for,3.19,1/7] rtlwifi: Remove logging statement that is no longer
> needed

I'll apply this after 3.20-rc1 is released, it should apply then without
problems (or the conflicts are easy for me to fix). Luckily this is just
a cosmetic error and can wait for 3.20-rc2, right?

> [V2,for,3.19,2/7] rtlwifi: rtl8192ee: Fix handling of new style descriptors
> [V2,for,3.19,6/7] rtlwifi: rtl8192ee: Fix problems with calculating free space in FIFO

Not sure what to do with these one. Should you rebase and send them now?

-- 
Kalle Valo
