From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/4] switchdev: don't support custom ip
 rules, for now
Date: Mon, 02 Mar 2015 15:40:21 -0500 (EST)
Message-ID: <20150302.154021.291909338132330257.davem@davemloft.net>
References: <54F4755F.6020205@cumulusnetworks.com>
	<CAE4R7bALEVb1reyCzfXXi=ifv97jy14ozQuxnG6x9BWmWX10Hg@mail.gmail.com>
	<54F4B56C.5040709@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457AbbCBUkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:40:24 -0500
In-Reply-To: <54F4B56C.5040709@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Mon, 02 Mar 2015 11:09:32 -0800

> On 3/2/15, 9:00 AM, Scott Feldman wrote:
>> On Mon, Mar 2, 2015 at 6:36 AM, roopa <roopa@cumulusnetworks.com>
>> wrote:
>>> On 3/2/15, 2:06 AM, sfeldma@gmail.com wrote:
>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>
>>>> Keep switchdev FIB offload model simple for now and don't allow custom
>>>> ip
>>>> rules.
>>>>
>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>>
>>> I don't see a need to do this. And seems very aggressive.
>>> Also, note that the rules in a system can be on non-hw accelerated
>>> ports.
>> It is aggressive but it's the safest choice for the first pass on this
>> L3 offload.  Without, switchdev has no way to model custom ip rules
>> down to hardware.   Let's start with this aggressive case, and that'll
>> force us to work on relaxing it.
>>
>>
> But, this will not allow hw acceleration of routes even if you had a
> rule for the management traffic for example.

We start simple, add complexity later.
