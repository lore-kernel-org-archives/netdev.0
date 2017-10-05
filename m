From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: Use put_unaligned_le32
Date: Thu, 05 Oct 2017 11:41:38 +0300
Message-ID: <87zi963s1p.fsf@codeaurora.org>
References: <1507141686-5178-1-git-send-email-himanshujha199640@gmail.com>
        <874lre5a86.fsf@codeaurora.org>
        <20171005083433.GA11485@himanshu-Vostro-3559>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amitkarwar@gmail.com, nishants@marvell.com, gbhat@marvell.com,
        huxm@marvell.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Himanshu Jha <himanshujha199640@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005083433.GA11485@himanshu-Vostro-3559> (Himanshu Jha's
        message of "Thu, 5 Oct 2017 14:04:33 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Himanshu Jha <himanshujha199640@gmail.com> writes:

>> > --- a/drivers/net/wireless/marvell/mwifiex/cmdevt.c
>> > +++ b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
>> > @@ -17,6 +17,7 @@
>> >   * this warranty disclaimer.
>> >   */
>> >  
>> > +#include <linux/unaligned/access_ok.h>
>> 
>> I don't think this is correct. Should it be asm/unaligned.h?
>
> Would mind explainig me as to why it is incorrect! Also, it defined in
> both the header files but, why is asm/unaligned.h preferred ?

asm/unaligned.h seems to be the toplevel header file which includes
header files based on arch configuration. Also grepping the sources
support that, nobody from drivers/ include access_ok.h directly.

But I can't say that I fully understand how the header files work so
please do correct me if I have mistaken.

-- 
Kalle Valo
