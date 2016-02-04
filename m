From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] rtlwifi: Fix improve function 'rtl_addr_delay()' in
 core.c
Date: Thu, 4 Feb 2016 09:43:58 -0600
Message-ID: <56B371BE.1060805@lwfinger.net>
References: <20160203015953.GA13562@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCD5486@AcuExch.aculab.com>
 <CAOxTRzpO4mx361GqA+W39bxSfbOCaiLw320S-aph1v1OGJ0FYw@mail.gmail.com>
 <56B258B2.6090802@lwfinger.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CCD61C8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"chaoming_li@realsil.com.cn" <chaoming_li@realsil.com.cn>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	ByeoungWook Kim <quddnr145@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD61C8@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/04/2016 03:48 AM, David Laight wrote:
> From: Larry Finger
>> Sent: 03 February 2016 19:45
> ...
>> The performance will depend on where you satisfy the condition. All switch cases
>> have the same execution time, but in the if .. else if .. else form, the earlier
>> tests execute more quickly. I'm not sure that one can make any blanket statement
>> about performance. Certainly, the switch version will be larger. For a switch
>> with 8 cases plus default, the object code if 43 bytes larger than the nested
>> ifs in a test program that I created. That is a significant penalty.
>
> There is also the penalty of the (likely) data cache miss reading the jump table.
> But given this code is all about generating a variable delay the execution
> speed is probably irrelevant.
>
> It would be much more interesting if the delay could be changed for sleeps.

Unfortunately, sleeping is not possible for the routines that call rtl_addr_delay().

Larry
