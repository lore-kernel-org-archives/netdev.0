From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Sat, 2 Jul 2016 10:26:21 -0400
Message-ID: <5777CF0D.4020509@mojatatu.com>
References: <1467465978-28271-1-git-send-email-jhs@emojatatu.com>
 <5777C673.8000703@cumulusnetworks.com> <5777C976.4000402@mojatatu.com>
 <5777CAB7.9050007@cumulusnetworks.com> <5777CCD1.8090404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37330 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbcGBO0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 10:26:23 -0400
Received: by mail-it0-f42.google.com with SMTP id f6so36437854ith.0
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 07:26:23 -0700 (PDT)
In-Reply-To: <5777CCD1.8090404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-02 10:16 AM, Jamal Hadi Salim wrote:
> On 16-07-02 10:07 AM, Nikolay Aleksandrov wrote:
>> On 02/07/16 16:02, Jamal Hadi Salim wrote:
>>> On 16-07-02 09:49 AM, Nikolay Aleksandrov wrote:
>
>>>> Also a minor suggestion - maybe err out on a
>>>> zero mac address, otherwise the user might think the operation was
>>>> successful.
>>>>
>>>
>>> Is a zero mac address wrong? What if that was policy intent?
>>>
>>
>> If you mean that you give the user ability to get rid of the mac, then
>> okay. I said it
>> because it will seem like a successful operation and then the mac will
>> not be dumped
>> or overwritten which will look like it wasn't set at all.
>>
>
> I mean a MAC address of all zeros.
> The destination MAC itself is optional attribute; if user doesnt pass it
> we (dont care and) never use it. Dumping will not see it and therefore
> not display it.
>

Actually it makes sense not to allow a MAC address of all zeros.
So I will add that check. Posting v2 shortly.

cheers,
jamal
