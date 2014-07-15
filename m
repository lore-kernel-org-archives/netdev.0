From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next] sfc: add extra RX drop counters for nodesc_trunc
 and noskb_drop
Date: Tue, 15 Jul 2014 18:02:25 +0530
Message-ID: <53C51F59.9010608@gmail.com>
References: <alpine.LFD.2.03.1407141534440.19512@solarflare.com> <53C50C35.80200@gmail.com> <53C51CD7.3030105@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Miller <davem@davemloft.net>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:43805 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567AbaGOMdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 08:33:38 -0400
Received: by mail-pd0-f180.google.com with SMTP id y13so4717531pdi.25
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 05:33:37 -0700 (PDT)
In-Reply-To: <53C51CD7.3030105@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 05:51 PM, Edward Cree wrote:
> On 15/07/14 12:10, Varka Bhadram wrote:
>> On 07/15/2014 04:28 PM, Edward Cree wrote:
>>> Added a counter rx_noskb_drop for failure to allocate an skb.
>>> Summed the per-channel rx_nodesc_trunc counters earlier so that they can
>>>    be included in rx_dropped.
>>>
>>>
>> check patch errors on this patch...  :-)
>>
> "Macros with complex values should be enclosed in parenthesis" is a
> false positive - the macro is for a structure initialiser.
> The long lines are both justifiable and only slightly over 80 columns.
> So checkpatch is just being fascist as usual ;)

I think we can fix those errors...  :-)

>
> -Edward
> The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.


-- 
Regards,
Varka Bhadram.
