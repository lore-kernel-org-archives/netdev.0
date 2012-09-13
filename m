From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC/RFT 14/15] rtlwifi: Modify files for addition of rtl8723ae
Date: Thu, 13 Sep 2012 00:36:06 -0500
Message-ID: <505170C6.8090003@lwfinger.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net> <1347483294-6943-15-git-send-email-Larry.Finger@lwfinger.net> <CAGRGNgWezEzXV0-k6DA7TckNpa=zgN6LNv898N-PRU6P1LYgOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, chaoming_li@realsil.com.cn
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:58528 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab2IMFgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 01:36:10 -0400
In-Reply-To: <CAGRGNgWezEzXV0-k6DA7TckNpa=zgN6LNv898N-PRU6P1LYgOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2012 10:11 PM, Julian Calaby wrote:
> Hi Larry,
>
> On Thu, Sep 13, 2012 at 6:54 AM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>> This patch modifies the files of rtlwifi for the addition of a new driver
>> to handle the Realtek RTL8723AE wireless device, and introduces a new
>> routine to maintaim statistics that will be used later for roaming.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> Cc: <chaoming_li@realsil.com.cn>
>> ---
>>   drivers/net/wireless/rtlwifi/debug.h |    2 +
>>   drivers/net/wireless/rtlwifi/pci.h   |    1 +
>>   drivers/net/wireless/rtlwifi/stats.c |  274 ++++++++++++++++++++++++++++++++++
>>   drivers/net/wireless/rtlwifi/stats.h |   47 ++++++
>>   4 files changed, 324 insertions(+)
>>   create mode 100644 drivers/net/wireless/rtlwifi/stats.c
>>   create mode 100644 drivers/net/wireless/rtlwifi/stats.h
>>
>> diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
>> index 07493d2..b81e299 100644
>> --- a/drivers/net/wireless/rtlwifi/debug.h
>> +++ b/drivers/net/wireless/rtlwifi/debug.h
>> @@ -106,6 +106,8 @@
>>   #define COMP_REGD                      BIT(27)
>>   #define COMP_CHAN                      BIT(28)
>>   #define COMP_USB                       BIT(29)
>> +#define COMP_EASY_CONCURRENT           BIT(29)
>
> Is this supposed to be bit #29 - I notice that COMP_USB is also bit 29.

Yes, that is OK. One will only be used for PCI-based drivers, and the other is 
obviously for USB. As nearly all the bits of a 32-bit quantity are used, I 
wanted to save one if possible.

In the final version, I'll code this as

#define COMP_USB                       BIT(29)
#define COMP_EASY_CONCURRENT           COMP_USB

That way will be more obvious.

Larry
