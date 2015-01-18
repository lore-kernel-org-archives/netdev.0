From: Andy Green <andy.green@linaro.org>
Subject: Re: [PATCH 5/7] net: wireless: wcn36xx: swallow two wcn3620 IND messages
Date: Sun, 18 Jan 2015 20:59:55 +0800
Message-ID: <CAAfg0W7nD9Jb7M3vhnkM6KaOrVOo+A_zvuQy1XUYM36KBzUH_Q@mail.gmail.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051105.31866.43889.stgit@114-36-241-182.dynamic.hinet.net>
	<54BB9D3C.90306@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:51985 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbbARM74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 07:59:56 -0500
Received: by mail-qa0-f42.google.com with SMTP id dc16so20824640qab.1
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 04:59:55 -0800 (PST)
In-Reply-To: <54BB9D3C.90306@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 January 2015 at 19:47, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 1/18/2015 8:11 AM, Andy Green wrote:
>
>> WCN3620 can asynchronously send two new kinds of indication message,
>> since we can't handle them just accept them quietly.
>
>
>> Signed-off-by: Andy Green <andy.green@linaro.org>
>> ---
>>   drivers/net/wireless/ath/wcn36xx/smd.c |    6 ++++++
>>   1 file changed, 6 insertions(+)
>
>
>> diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c
>> b/drivers/net/wireless/ath/wcn36xx/smd.c
>> index 6398693..819741c 100644
>> --- a/drivers/net/wireless/ath/wcn36xx/smd.c
>> +++ b/drivers/net/wireless/ath/wcn36xx/smd.c
>
> [...]
>>
>> @@ -2107,6 +2109,10 @@ static void wcn36xx_ind_smd_work(struct work_struct
>> *work)
>>         msg_header = (struct wcn36xx_hal_msg_header *)hal_ind_msg->msg;
>>
>>         switch (msg_header->msg_type) {
>> +       case WCN36XX_HAL_COEX_IND:
>> +               break;
>> +       case WCN36XX_HAL_AVOID_FREQ_RANGE_IND:
>> +               break;
>
>
>    Can't you merge these 2 cases, so that there's only one *break*?

Yes will do.

-Andy

> [...]
>
> WBR, Sergei
>
