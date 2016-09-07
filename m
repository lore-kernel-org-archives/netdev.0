From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ath9k: bring back direction setting in ath9k_{start_stop}
Date: Wed, 07 Sep 2016 16:16:09 +0300
Message-ID: <8737lbx33a.fsf@kamboji.qca.qualcomm.com>
References: <e61bb634860745818f8c8c99f79f71a0@euamsexm01a.eu.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: <ath9k-devel@qca.qualcomm.com>, <linux-wireless@vger.kernel.org>,
        <ath9k-devel@lists.ath9k.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        Miaoqing Pan <miaoqing@codeaurora.org>,
        <stable@vger.kernel.org>
To: Giedrius Statkevi?ius <giedrius.statkevicius@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e61bb634860745818f8c8c99f79f71a0@euamsexm01a.eu.qualcomm.com>
        (Kalle Valo's message of "Wed, 7 Sep 2016 15:11:44 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kalle Valo <kvalo@qca.qualcomm.com> writes:

> Giedrius Statkevi?ius <giedrius.statkevicius@gmail.com> wrote:
>> A regression was introduced in commit id 79d4db1214a ("ath9k: cleanup
>> led_pin initial") that broken the WLAN status led on my laptop with
>> AR9287 after suspending and resuming.
>> 
>> Steps to reproduce:
>> * Suspend (laptop)
>> * Resume (laptop)
>> * Observe that the WLAN led no longer turns ON/OFF depending on the
>>   status and is always red
>> 
>> Even though for my case it only needs to be set to OUT in ath9k_start
>> but for consistency bring back the IN direction setting as well.
>> 
>> Cc: Miaoqing Pan <miaoqing@codeaurora.org>
>> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Giedrius Statkevičius <giedrius.statkevicius@gmail.com>
>
> Thanks, 1 patch applied to ath-next branch of ath.git:
>
> 088a60926b66 ath9k: bring back direction setting in ath9k_{start_stop}

Oops, I was supposed to apply this to ath-current branch. Please ignore
this. Luckily I didn't push yet so I can easily fix this.

-- 
Kalle Valo
