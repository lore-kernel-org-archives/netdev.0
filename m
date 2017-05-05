From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] iproute2: hide devices starting with period by default
Date: Fri, 5 May 2017 09:42:06 +0200
Message-ID: <15431948-fc31-ad01-e1eb-02e025b91f59@6wind.com>
References: <027775d1-ef98-deda-1f8d-bb058d1e4c2f@cumulusnetworks.com>
 <20170223163035.0a49f04d@xeon-e3>
 <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
 <20170223.221257.795227595252531962.davem@redhat.com>
 <0a8e1cf0-9f30-2356-5168-a97abb86d5c2@cumulusnetworks.com>
 <0635d3bb-0d8d-7ab6-fb53-4d84f979a023@6wind.com>
 <4bbb7a19-1b0b-8c9a-7e74-82ee146cf48c@gmail.com>
 <26442035-25fd-ff9a-2804-ed21ec6198cf@gmail.com>
 <01aa60dc-8bf2-3207-1abe-158100f52960@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@redhat.com>, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35204 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751616AbdEEHmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 03:42:10 -0400
Received: by mail-wm0-f46.google.com with SMTP id w64so16342862wma.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 00:42:10 -0700 (PDT)
In-Reply-To: <01aa60dc-8bf2-3207-1abe-158100f52960@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/05/2017 à 21:47, David Ahern a écrit :
> On 5/4/17 1:10 PM, Florian Fainelli wrote:
>> On 05/04/2017 09:37 AM, David Ahern wrote:
>>> On 5/4/17 9:15 AM, Nicolas Dichtel wrote:
>>>> Le 24/02/2017 à 16:52, David Ahern a écrit :
>>>>> On 2/23/17 8:12 PM, David Miller wrote:
>>>>>> This really need to be a fundamental facility, so that it transparently
>>>>>> works for NetworkManager, router daemons, everything.  Not just iproute2
>>>>>> and "ls".
>>>>>
>>>>> I'll rebase my patch and send out as RFC.
>>>>>
>>>> David, did you finally send those patches?
>>>>
>>>
>>> No, but for a few reasons.
>>>
>>> It is easy to hide devices in a dump:
>>>
>>> https://github.com/dsahern/linux/commit/48a80a00eac284e58bae04af10a5a932dd7aee00
>>>
>>>
>>> But I think those devices should also not exist in sysfs or procfs which
>>> overlaps what I would like to see for lightweight netdevices:
>>>
>>> https://github.com/dsahern/linux/commit/70574be699cf252e77f71e3df11192438689f976
>>
>> Interesting that does indeed solve the same problems as the L2 only
>> patch set intended. I am not exactly sure if hiding the devices from
>> procfs/sysfs would be appropriate in my case (dumb L2 only switch that
>> only does 802.1q for instance), but why not.
>>
>>
>>>
>>>
>>> and to be complete, hidden devices should not be allowed to have a
>>> network address or transmit packets which is the L2 only intent from
>>> Florian:
>>>     https://www.spinics.net/lists/netdev/msg340808.html
>>>
>>
>> Do you plan on submitting the LWT patch set at some point?
> 
> Definitely. Maybe I can find some time this weekend.
> 
Ok, thank you for the details.

I agree with Jiri that the name should be something different than lwt.


Regards,
Nicolas
