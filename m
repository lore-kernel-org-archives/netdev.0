From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Wed, 13 May 2015 12:13:17 -0400 (EDT)
Message-ID: <20150513.121317.888001972945997230.davem@davemloft.net>
References: <20150513054250.GA2126@nanopsycho>
	<55530ABE.8040503@iogearbox.net>
	<555353BA.5010103@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jiri@resnulli.us, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965293AbbEMQNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 12:13:20 -0400
In-Reply-To: <555353BA.5010103@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Wed, 13 May 2015 06:38:02 -0700

> On 5/13/15, 1:26 AM, Daniel Borkmann wrote:
>> On 05/13/2015 07:42 AM, Jiri Pirko wrote:
>>> Wed, May 13, 2015 at 07:27:10AM CEST, roopa@cumulusnetworks.com wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.
>>>>
>>>> This patch renames the flag to be consistent with what the user sees.
>>>>
>>>> (I will post iproute2 patch if this gets accepted)
>>>>
>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>> ---
>>>> include/uapi/linux/rtnetlink.h |    2 +-
>>>> net/ipv4/fib_trie.c            |    2 +-
>>>> net/switchdev/switchdev.c      |    6 +++---
>>>> 3 files changed, 5 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/include/uapi/linux/rtnetlink.h
>>>> b/include/uapi/linux/rtnetlink.h
>>>> index 974db03..17fb02f 100644
>>>> --- a/include/uapi/linux/rtnetlink.h
>>>> +++ b/include/uapi/linux/rtnetlink.h
>>>> @@ -337,7 +337,7 @@ struct rtnexthop {
>>>> #define RTNH_F_DEAD 1 /* Nexthop is dead (used by multipath) */
>>>> #define RTNH_F_PERVASIVE    2    /* Do recursive gateway lookup    */
>>>> #define RTNH_F_ONLINK        4    /* Gateway is forced on link    */
>>>> -#define RTNH_F_EXTERNAL        8    /* Route installed externally    */
>>>> +#define RTNH_F_OFFLOAD        8    /* offloaded route */
>>>
>>> Since this is part of uapi, I believe this is not doable :/
> i thought it was not too late :) and besides i wasn't changing the
> value and just the name.
> current iproute2 would still build for example.

If it made it into a release kernel, you cannot change it.

Period.
