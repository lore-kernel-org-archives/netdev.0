From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Wed, 13 May 2015 06:38:02 -0700
Message-ID: <555353BA.5010103@cumulusnetworks.com>
References: <1431494830-4284-1-git-send-email-roopa@cumulusnetworks.com> <20150513054250.GA2126@nanopsycho> <55530ABE.8040503@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	sfeldma@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36298 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809AbbEMNiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 09:38:04 -0400
Received: by pdea3 with SMTP id a3so51960159pde.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 06:38:04 -0700 (PDT)
In-Reply-To: <55530ABE.8040503@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/15, 1:26 AM, Daniel Borkmann wrote:
> On 05/13/2015 07:42 AM, Jiri Pirko wrote:
>> Wed, May 13, 2015 at 07:27:10AM CEST, roopa@cumulusnetworks.com wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.
>>>
>>> This patch renames the flag to be consistent with what the user sees.
>>>
>>> (I will post iproute2 patch if this gets accepted)
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> ---
>>> include/uapi/linux/rtnetlink.h |    2 +-
>>> net/ipv4/fib_trie.c            |    2 +-
>>> net/switchdev/switchdev.c      |    6 +++---
>>> 3 files changed, 5 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/include/uapi/linux/rtnetlink.h 
>>> b/include/uapi/linux/rtnetlink.h
>>> index 974db03..17fb02f 100644
>>> --- a/include/uapi/linux/rtnetlink.h
>>> +++ b/include/uapi/linux/rtnetlink.h
>>> @@ -337,7 +337,7 @@ struct rtnexthop {
>>> #define RTNH_F_DEAD        1    /* Nexthop is dead (used by 
>>> multipath)    */
>>> #define RTNH_F_PERVASIVE    2    /* Do recursive gateway lookup    */
>>> #define RTNH_F_ONLINK        4    /* Gateway is forced on link    */
>>> -#define RTNH_F_EXTERNAL        8    /* Route installed 
>>> externally    */
>>> +#define RTNH_F_OFFLOAD        8    /* offloaded route */
>>
>> Since this is part of uapi, I believe this is not doable :/
i thought it was not too late :) and besides i wasn't changing the value 
and just the name.
current iproute2 would still build for example.
>
> You could still alias it if necessary:
>
>   #define RTNH_F_OFFLOAD    RTNH_F_EXTERNAL
that is an option. hmm...wondering if it is worth creating an alias or 
we should live with it.
If i get more votes, i will resubmit.

thanks!.
