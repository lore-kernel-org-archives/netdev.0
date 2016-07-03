From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 1/4] net: ethernet: ti: davinci_cpdma: split descs num
 between all channels
Date: Sun, 3 Jul 2016 11:57:18 +0300
Message-ID: <5778D36E.2040803@linaro.org>
References: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1467313478-22919-2-git-send-email-ivan.khoronzhuk@linaro.org>
 <20160701.163506.323242842287789721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, nsekhar@ti.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160701.163506.323242842287789721.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 01.07.16 23:35, David Miller wrote:
> From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Date: Thu, 30 Jun 2016 22:04:35 +0300
>
>> @@ -720,7 +763,7 @@ unlock_ret:
>>   }
>>   EXPORT_SYMBOL_GPL(cpdma_chan_submit);
>>
>> -bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
>> +inline bool cpdma_check_free_desc(struct cpdma_chan *chan)
>>   {
>
> This needs to be marked static.
>
Yes. Will correct it.

-- 
Regards,
Ivan Khoronzhuk
