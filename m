From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: AW: Redundancy support through HSR and PRP
Date: Thu, 27 Oct 2016 18:54:13 -0400
Message-ID: <58128595.8090708@ti.com>
References: <57FBDF33.1060606@ti.com> <5808F9FC.1080802@ti.com>
 <580E3854.4030009@ti.com>
 <6075_1477400598_580F5816_6075_378_9_580F5825.9080109@alten.se>
 <5027_1477401856_580F5D00_5027_1483_1_48dbc6a7637e4ed8a1bec40e850061b8@DE0-03DAG08-P03.central.mail.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: "HEISE, Peter P" <peter.heise@airbus.com>,
        Arvid Brodin <arvid.brodin@alten.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:37599 "EHLO comal.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935281AbcJ0WyX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 18:54:23 -0400
In-Reply-To: <5027_1477401856_580F5D00_5027_1483_1_48dbc6a7637e4ed8a1bec40e850061b8@DE0-03DAG08-P03.central.mail.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2016 09:24 AM, HEISE, Peter P wrote:
> Hi Murali, hi Arvid,
> 
> also no work on PRP from my side.
> 
> Should be pretty straight forward to get PRP support from the existing HSR code.

Thanks Arvid and Peter!

Basically I have following to be done w.r.t HSR/PRP.

1. Add PRP support
2. Add h/w offload some of the rx/tx redundancy and L2 forward handling to firmware.

If you have any thoughts on 2, please let me know. Our hardware is a switch
with HSR/PRP support. So I believe I need to have L2 offload done using the DSA
and run the hsr/prp driver on top of that. The MIB handling is done in the
firmware. So that has to be offloaded as well. My work has just begun and I hope
to come up with an RFC patch for HSR offload first followed by PRP support.

>From high level, it appears to be a straight forward to add the PRP support.
I might have to rename the net/hsr to something like net/hsr-prp ??

Also restructure the code a bit to support PRP

I have brought up HSR driver on my platform (HSRv0 and HSRv1) and it seems to work.
So I might be able to regress the existing once I add my change.

Peter,

Do you think you could help me do some testing in the future when patches become
available?

Murali

> 
> 
> -----Ursprüngliche Nachricht-----
> Von: Arvid Brodin [mailto:arvid.brodin@alten.se] 
> Gesendet: Dienstag, 25. Oktober 2016 15:04
> An: Murali Karicheri
> Cc: open list:TI NETCP ETHERNET DRIVER; David Miller; HEISE, Peter P
> Betreff: Re: Redundancy support through HSR and PRP
> 
> On 2016-10-24 18:35, Murali Karicheri wrote:
>>> On 10/10/2016 02:34 PM, Murali Karicheri wrote:
>>>> All,
>>>>
>>>> Wondering if there plan to add PRP driver support, like HSR in 
>>>> Linux? AFAIK, PRP adds trailor to Ethernet frame and is used for Redundancy management like HSR.
>>>> So wondering why this is not supported.
>>>>
>>>> Thanks
>>>>
>>> I need to work on a prp driver for Linux. So if there is already 
>>> someone working on this, I would like to join and contribute. Either 
>>> way please respond so that I can work to add this support.
>>>
>> + Arvid
>>
>> Didn't copy HSR owner in my original email. Copying now.
>>
> 
> Hi Murali,
> 
> I'm not aware of anyone working on PRP support.
> 
> I will have very little time, if any, to help out with this (or even test changes).
> In fact, if you want to send a patch for the MAINTAINERS file to take over maintainership of the HSR/PRP driver, that would probably be a good thing.
> 
> (I'm CC'ing also Peter Heise to this conversation, since he's done some recent work on the HSR driver, and might want to keep updated.)
> 
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
