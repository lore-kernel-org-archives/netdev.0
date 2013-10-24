From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: Bluetooth 6LoWPAN and routing
Date: Thu, 24 Oct 2013 15:48:17 +0300
Message-ID: <52691711.3010909@linux.intel.com>
References: <5268C214.2040307@linux.intel.com> <20131024122452.GA5491@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3287 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755123Ab3JXMsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 08:48:20 -0400
In-Reply-To: <20131024122452.GA5491@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

On 24.10.2013 15:25, Alexander Aring wrote:
> Hi Jukka,
>
> On Thu, Oct 24, 2013 at 09:45:40AM +0300, Jukka Rissanen wrote:
>> Hi,
>>
>> I have been prototyping with BT 6LoWPAN support (using this draft
>> http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12 as a
>> reference). I sent first version yesterday to linux-bluetooth ml
>> http://thread.gmane.org/gmane.linux.bluez.kernel/39394
>>
> I see you take many code from the 6lowpan ieee802154 implementation.
> (Just notice you drop the original authors from there)

Hmm, those got dropped, I am sorry about that. I will add the original 
authors information of course.

>
> I have a couple of patches to fix a lot of bugs in the current 6LoWPAN
> ieee802154 implementation.
>
> Some bugs which I found:
>
>    - Fix race conditions in fragmentation handling
>    - Fix UDP compression/uncompressionm, which is completly broken
>    - Fragmentation handling isn't rfc4944 compatible
>
> And some other improvements. I see your rfc has the same issues (e.g.
> fragmentation race conditions).
>
> Currently I preparing these patches for mainlining.

Excellent news!

>
> But my question is:
>
> What we do now, make a generic 6LoWPAN implementation. Or bluetooth,
> ieee802154 makes his own implementation?

At least the compression/uncompression code and fragmentation could be 
shared. Could it possible to isolate relevant functions to separate file 
that would be usable by both BT and ieee802154?

>
> - Alex
>

-- 
Cheers,
Jukka
