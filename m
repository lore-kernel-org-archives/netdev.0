From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH V2 for 3.19 0/7] Fixes for rtl8192ee
Date: Fri, 23 Jan 2015 17:26:00 +0200
Message-ID: <873871msc7.fsf@kamboji.qca.qualcomm.com>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:47443 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127AbbAWP0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:26:08 -0500
In-Reply-To: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
	(Larry Finger's message of "Tue, 20 Jan 2015 11:01:19 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

> This is V2 of the patches for rtl8192ee to be applied to 3.19. They replace
> all the patches submitted under the title '[PATCH for 3.19 0/3] rtlwifi:
> Various updates/fixes". All are marked for backporting to 3.18.
>
> The first of these removes a logging statement that is no longer needed.
>
> Patches 1-6 are relatively small and should not be a problem for 3.19.
> Patch 7 is quite a bit larger, and adds two new routines to detect
> DMA stalls. I will understand if you want to defer that to -next; however,
> it does fix a serious problem.

-rc6 is most likely released on Sunday, I cannot send six patches this
late in the cycle unless our inboxes are filling of bug reports. As my
inbox seems to be pretty empty about rtlwifi problems can you give more
background why you think it's important to get these to 3.19? Are these
all regressions from 3.18 or older bugs which just got fixed now?

>   rtlwifi: Remove logging statement that is no longer needed

I think this is ok.

>   rtlwifi: rtl8192ee: Fix adhoc fail

Ad-Hoc mode is not that popular, IMHO this can easily wait for -next.

>   rtlwifi: rtl8192ee: Fix problems with calculating free space in FIFO
>   rtlwifi: rtl8192ee: Fix handling of new style descriptors
>   rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write
>     point
>   rtlwifi: rtl8192ee: Fix parsing of received packet
>   rtlwifi: rtl8192ee: Fix DMA stalls

For -rc1 or -rc2 these would have been ok, but without really good
justifications getting these into -rc7 is difficult.

But the patches itself are create, huge improvement compared to v1.

-- 
Kalle Valo
