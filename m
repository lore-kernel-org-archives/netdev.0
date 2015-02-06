From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 14/29] net: vrf: Introduce vrf header file
Date: Thu, 05 Feb 2015 17:52:24 -0700
Message-ID: <54D41048.4050608@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-15-git-send-email-dsahern@gmail.com> <54D373D0.40405@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:47253 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbbBFAwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:52:30 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so3514975igd.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 16:52:29 -0800 (PST)
In-Reply-To: <54D373D0.40405@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 6:44 AM, Nicolas Dichtel wrote:
> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
>> Defines for min and max vrf id and helpers for examining
>>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
>> ---
>>   include/net/vrf.h | 36 ++++++++++++++++++++++++++++++++++++
>>   1 file changed, 36 insertions(+)
>>   create mode 100644 include/net/vrf.h
>>
>> diff --git a/include/net/vrf.h b/include/net/vrf.h
>> new file mode 100644
>> index 000000000000..67bc2e465661
>> --- /dev/null
>> +++ b/include/net/vrf.h
>> @@ -0,0 +1,36 @@
>> +#ifndef _VRF_H_
>> +#define _VRF_H_
>> +
>> +#define VRF_BITS    12
>> +#define VRF_MIN        1
>> +#define VRF_MAX        ((1 << VRF_BITS) - 1)
>> +#define VRF_MASK    VRF_MAX
>> +
>> +#define VRF_DEFAULT    1
>> +#define VRF_ANY        0xffff
> It could be useful to expose this value to userland.

Maybe. I was thinking VRF_ANY should stay kernel side only and have a=20
sockopt value of -1 mean VRF_ANY.

David
