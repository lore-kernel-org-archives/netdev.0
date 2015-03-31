From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 13/18] switchdev: remove unused NETIF_F_HW_SWITCH_OFFLOAD
Date: Tue, 31 Mar 2015 09:03:52 -0700
Message-ID: <CAE4R7bCgccSSgKqjW_EVm3s=Q5aAx39a9-dqRQpgk7K_tKWkqw@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-14-git-send-email-sfeldma@gmail.com>
	<551951CD.1060301@cumulusnetworks.com>
	<CAE4R7bDBdjvZ0VAzX19ZP3h4i9GpNnXyO6RqgKMNnHx0em_x9A@mail.gmail.com>
	<CAJieiUiL4QRQAC30=bkYadYD2L2cOcn7mNLV98uH3Go0exMO+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:32768 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbbCaQDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 12:03:53 -0400
Received: by qcrf4 with SMTP id f4so4925491qcr.0
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 09:03:53 -0700 (PDT)
In-Reply-To: <CAJieiUiL4QRQAC30=bkYadYD2L2cOcn7mNLV98uH3Go0exMO+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 8:31 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>
> On Monday, March 30, 2015, Scott Feldman <sfeldma@gmail.com> wrote:
>>
>> On Mon, Mar 30, 2015 at 6:38 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> > On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
>> >>
>> >> From: Scott Feldman <sfeldma@gmail.com>
>> >>
>> >> Flag is no longer needed so remove it.  Using the attr get/set recurse
>> >> algo
>> >> obsoletes the flag.  Setting the flag on bond/team interface, even when
>> >> the
>> >> consitient member ports didn't have flag set was confusing.
>> >>
>> >> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> >
>> >
>> > The flag was there to avoid the recursive lowerdev walk where possible.
>> > bond will have the flag if any one slave can have it. You don't walk the
>> > bond if it does not have the flag.
>>
>> Ok, I see.  I'll remove this patch from set.  Should I put the
>> NETIF_F_HW_SWITCH_OFFLOAD check in the get/set attr wrappers?
>
>
> would be nice. Thanks scott.

Ok, it's back.  I'll send v2 tonight which addresses the review
comments and solves the vlan issues once and for all (I hope).
