From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] ravb: add sleep PM suspend/resume support
Date: Wed, 10 Aug 2016 13:47:26 +0300
Message-ID: <79a23b1c-9f73-e004-87d9-256bc408e633@cogentembedded.com>
References: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se>
 <20160803135647.23242-3-niklas.soderlund+renesas@ragnatech.se>
 <20160809.161636.2181233072433514866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	wsa@the-dreams.de
To: David Miller <davem@davemloft.net>,
	niklas.soderlund+renesas@ragnatech.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37783 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088AbcHJSNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:13:21 -0400
Received: by mail-wm0-f51.google.com with SMTP id i5so121643248wmg.0
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 11:13:20 -0700 (PDT)
In-Reply-To: <20160809.161636.2181233072433514866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/10/2016 2:16 AM, David Miller wrote:

>> The interface would not function after the system had been woken up
>> after have been suspended (echo mem > /sys/power/state) cycle. The
>> reason for this is that all device registers have been reset to its
>> default values. This patch adds sleep suspend and resume functions that
>> detached the interface at suspend and restore the registers and reattach
>> the interface at resume.
>>
>> Only the registers that are only configured at probe time needs to be
>> explicitly restored by the resume handler. All other registers are
>> reconfigured by either reopening the device in the resume handler (if
>> the device was running when the system was suspended) or when the
>> interface is opened by a user at a later time.
>>
>> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
>
> Applied to net-next, thanks.

    Ugh, I should have reviewed the patch earlier -- I was postponing this 
until I have the time to test it... Since the patch did have some visible 
issues, it should've been recast before applying. DaveM, please in the future 
could you ping me before merging?

MBR, Sergei
