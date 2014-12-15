From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 v4] ip: Simplify executing ip cmd within network
 ns
Date: Mon, 15 Dec 2014 18:30:25 +0100
Message-ID: <548F1AB1.6080601@6wind.com>
References: <1418422507-6635-1-git-send-email-vadim4j@gmail.com> <20141213082936.GA1849@nanopsycho.orion> <20141213084243.GA3284@angus-think.lan> <20141213085803.GA12446@angus-think.lan> <20141213133210.GA12291@angus-think.lan> <20141213152024.GB1849@nanopsycho.orion>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42085 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbaLORa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 12:30:28 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so9673695wiw.1
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 09:30:27 -0800 (PST)
In-Reply-To: <20141213152024.GB1849@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/12/2014 16:20, Jiri Pirko a =E9crit :
> Sat, Dec 13, 2014 at 02:32:10PM CET, vadim4j@gmail.com wrote:
>> On Sat, Dec 13, 2014 at 10:58:03AM +0200, vadim4j@gmail.com wrote:
>>> On Sat, Dec 13, 2014 at 10:42:43AM +0200, vadim4j@gmail.com wrote:
>>>> On Sat, Dec 13, 2014 at 09:29:36AM +0100, Jiri Pirko wrote:
>>>>> Fri, Dec 12, 2014 at 11:15:07PM CET, vadim4j@gmail.com wrote:
>>>>>> From: Vadim Kochan <vadim4j@gmail.com>
>>>>>>
>>>>>> Added new '-netns' option to simplify executing following cmd:
>>>>>>
>>>>>>     ip netns exec NETNS ip OPTIONS COMMAND OBJECT
>>>>>>
>>>>>>     to
>>>>>>
>>>>>>     ip -n[etns] NETNS OPTIONS COMMAND OBJECT
>>>>>>
>>>>>> e.g.:
>>>>>>
>>>>>>     ip -net vnet0 link add br0 type bridge
>>>>>>     ip -n vnet0 link
>>>>>>
>>>>>> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>>>>>
>>>>>
>>>>> This looks good. I'm still missing support in tc, bridge, etc. I =
think
>>>>> it would be great to do this in the same patch/patchset.
>>>>>
>>>>   I planned to do this in the future patches after this main
>>>>   changes will be accepted. Actually adding this option to other
>>>>   tools is trivial.
>>>>
>>>>   Anyway may be I will re-send v5 with supporting of these tools i=
f I will have time.
>>>>
>>>>   Regards,
>>>
>>> BTW, some tools already have '-n' option, so I think only '-net' ca=
n be
>>> used in such cases.
>
>
> Yep, that is my point. I would like to have the same option for all.
Agreed. The real option name is '-netns'. The fact that '-n' will work =
comes
from how 'ip' is implemented. This kind of shortcut will depend on each=
 tool
implementation. But again, the *real* option name is '-netns' ;-)


Regards,
Nicolas
