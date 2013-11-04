From: Claudio Takahasi <claudio.takahasi@openbossa.org>
Subject: Re: Bluetooth 6LoWPAN and routing
Date: Mon, 4 Nov 2013 19:46:06 -0200
Message-ID: <CAKT1EBeHs4T3YiFvze2RBbM537pXEj03gTcnCMEZprdBz882hg@mail.gmail.com>
References: <5268C214.2040307@linux.intel.com>
	<20131024122452.GA5491@omega>
	<52691711.3010909@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:60055 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab3KDVqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 16:46:06 -0500
Received: by mail-pb0-f53.google.com with SMTP id up7so7607138pbc.26
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 13:46:06 -0800 (PST)
In-Reply-To: <52691711.3010909@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

On Thu, Oct 24, 2013 at 9:48 AM, Jukka Rissanen
<jukka.rissanen@linux.intel.com> wrote:
> Hi Alexander,
>
>
> On 24.10.2013 15:25, Alexander Aring wrote:
>>
>> Hi Jukka,
>>
>> On Thu, Oct 24, 2013 at 09:45:40AM +0300, Jukka Rissanen wrote:
>>>
>>> Hi,
>>>
>>> I have been prototyping with BT 6LoWPAN support (using this draft
>>> http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12 as a
>>> reference). I sent first version yesterday to linux-bluetooth ml
>>> http://thread.gmane.org/gmane.linux.bluez.kernel/39394
>>>
>> I see you take many code from the 6lowpan ieee802154 implementation.
>> (Just notice you drop the original authors from there)
>
>
> Hmm, those got dropped, I am sorry about that. I will add the original
> authors information of course.
>
>
>>
>> I have a couple of patches to fix a lot of bugs in the current 6LoWPAN
>> ieee802154 implementation.
>>
>> Some bugs which I found:
>>
>>    - Fix race conditions in fragmentation handling
>>    - Fix UDP compression/uncompressionm, which is completly broken
>>    - Fragmentation handling isn't rfc4944 compatible
>>
>> And some other improvements. I see your rfc has the same issues (e.g.
>> fragmentation race conditions).
>>
>> Currently I preparing these patches for mainlining.
>
>
> Excellent news!


Is it necessary to implement 6loWPAN fragmentation/reassembling? For
Bluetooth, I thought L2CAP FAR (Fragmentation and Reassembling) could
handle the transfer of IPv6 packets that doesn't fit in one single
BTLE PDU.
What am I missing here?

It seems that some BLE development kits/firmwares don't support FAR on
L2CAP Basic Mode, but this is another problem that should be fixed
soon.

Regards,
Claudio
