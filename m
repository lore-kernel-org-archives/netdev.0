From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 13/18] switchdev: remove unused NETIF_F_HW_SWITCH_OFFLOAD
Date: Tue, 31 Mar 2015 08:34:34 -0700
Message-ID: <551ABE8A.3080702@cumulusnetworks.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com> <1427704836-8776-14-git-send-email-sfeldma@gmail.com> <551951CD.1060301@cumulusnetworks.com> <CAE4R7bDBdjvZ0VAzX19ZP3h4i9GpNnXyO6RqgKMNnHx0em_x9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35000 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbbCaPeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 11:34:36 -0400
Received: by patj18 with SMTP id j18so23000981pat.2
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 08:34:36 -0700 (PDT)
In-Reply-To: <CAE4R7bDBdjvZ0VAzX19ZP3h4i9GpNnXyO6RqgKMNnHx0em_x9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/15, 2:20 PM, Scott Feldman wrote:
> On Mon, Mar 30, 2015 at 6:38 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> Flag is no longer needed so remove it.  Using the attr get/set recurse
>>> algo
>>> obsoletes the flag.  Setting the flag on bond/team interface, even when
>>> the
>>> consitient member ports didn't have flag set was confusing.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>
>> The flag was there to avoid the recursive lowerdev walk where possible.
>> bond will have the flag if any one slave can have it. You don't walk the
>> bond if it does not have the flag.
> Ok, I see.  I'll remove this patch from set.  Should I put the
> NETIF_F_HW_SWITCH_OFFLOAD check in the get/set attr wrappers?
>
that would be nice. Thanks scott
