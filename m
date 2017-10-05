From: Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>
Subject: Re: [PATCH] mwifiex: Use put_unaligned_le32
Date: Thu, 5 Oct 2017 14:54:38 -0700
Message-ID: <357bb728-f324-5c9f-c92c-08c57f22ce75@quantenna.com>
References: <1507141686-5178-1-git-send-email-himanshujha199640@gmail.com>
 <874lre5a86.fsf@codeaurora.org> <20171005083433.GA11485@himanshu-Vostro-3559>
 <87zi963s1p.fsf@codeaurora.org> <20171005152233.GA6250@himanshu-Vostro-3559>
 <20171005180248.GA94139@google.com>
 <20171005190730.GA8043@himanshu-Vostro-3559>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, amitkarwar@gmail.com,
        nishants@marvell.com, gbhat@marvell.com, huxm@marvell.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Himanshu Jha <himanshujha199640@gmail.com>,
        Brian Norris <briannorris@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005190730.GA8043@himanshu-Vostro-3559>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/05/2017 12:07 PM, Himanshu Jha wrote:
>>
>> In this case, the key is CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS. It
>> seems that asm-generic/unaligned.h is set up to include different
>> headers, based on the expected architecture behavior.
>>
> Yes, asm-generic/unaligned.h looks more appopriate and is most generic
> implementation of unaligned accesses and  arc specific.
> 

Probably the idea is that each ARCH knows exactly what is the best way 
to do unaligned access, so common code (like drivers) should include 
ARCH-specific asm/unaligned.h only. It will then decide how to do that 
and will include asm-generic/unaligned.h itself, if required.
