From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 3/8] mISDN: avmfritz use the bigger fifo of chip version
 2
Date: Wed, 16 May 2012 09:00:11 +0200
Message-ID: <4FB3507B.10808@linux-pingi.de>
References: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de> <1337142174-8304-4-git-send-email-kkeil@linux-pingi.de> <20120516.011615.2055798345695085276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:58266 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966280Ab2EPJAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 05:00:03 -0400
In-Reply-To: <20120516.011615.2055798345695085276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16.05.2012 07:16, schrieb David Miller:
> From: Karsten Keil<kkeil@linux-pingi.de>
> Date: Wed, 16 May 2012 06:22:49 +0200
>
>> +	mode = (AVM_FRITZ_PCIV2 == fc->type) ? HDLC_FIFO_SIZE_128 : 0;
>
> Please don't do this "CONSTANT == variable" type testing order, it's
> completely unnatural and not something we commonly do elsewhere in the
> networking code.
>

I fully agree, looks much better.

> I know some coders bible somewhere says that this is how you avoid
> accidental assignments, but it's too ugly to live.

With todays compilers as long you do not disable/ignore warnings it 
should be safe as well.

Will send version 2 of the patchset soon (with all other issues fixed too)

Karsten
