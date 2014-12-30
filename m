From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [RFC PATCH net-next 0/5]: ixgbevf: Allow querying VFs RSS indirection
 table and key
Date: Tue, 30 Dec 2014 21:30:52 +0200
Message-ID: <54A2FD6C.6050807@cloudius-systems.com>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>	 <CAL3LdT73zfJwNcHS0ZpZ=ZzG=UiCUW5UEnOF9Fp2rR0e-ejXYg@mail.gmail.com>	 <CAOYyTHb+5Wc-e3vBVE+MCh6YNfmompi9Mnsr0nDnHAn7Tvqyew@mail.gmail.com>	 <1419965520.31582.20.camel@jtkirshe-mobl>	 <CAOYyTHathHiGThyHj+yRi9O6jWEAO3wkAK-6egMc2OwK9dQoMQ@mail.gmail.com> <1419967707.31582.23.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gleb Natapov <gleb@cloudius-systems.com>,
	avi@cloudius-systems.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:52046 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbaL3TbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 14:31:01 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so24596489wid.6
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 11:31:00 -0800 (PST)
In-Reply-To: <1419967707.31582.23.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/30/14 21:28, Jeff Kirsher wrote:
> On Tue, 2014-12-30 at 21:00 +0200, Vladislav Zolotarov wrote:
>> On Dec 30, 2014 8:52 PM, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
>> wrote:
>>> On Tue, 2014-12-30 at 20:50 +0200, Vladislav Zolotarov wrote:
>>>> On Dec 30, 2014 8:16 PM, "Jeff Kirsher"
>> <jeffrey.t.kirsher@intel.com>
>>>> wrote:
>>>>> On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
>>>>> <vladz@cloudius-systems.com> wrote:
>>>>>> Add the ethtool ops to VF driver to allow querying the RSS
>>>> indirection table
>>>>>> and RSS Random Key.
>>>>>>
>>>>>>   - PF driver: Add new VF-PF channel commands.
>>>>>>   - VF driver: Utilize these new commands and add the
>> corresponding
>>>>>>                ethtool callbacks.
>>>>>>
>>>>>> Vlad Zolotarov (5):
>>>>>>    ixgbe: Add a RETA query command to VF-PF channel API
>>>>>>    ixgbevf: Add a RETA query code
>>>>>>    ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>>>>>>    ixgbevf: Add RSS Key query code
>>>>>>    ixgbevf: Add the appropriate ethtool ops to query RSS
>>>> indirection
>>>>>>      table and key
>>>>>>
>>>>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   8 ++
>>>>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  60
>>>> +++++++++++
>>>>>>   drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  37
>> +++++++
>>>>>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>>>>>>   drivers/net/ethernet/intel/ixgbevf/mbx.h          |   8 ++
>>>>>>   drivers/net/ethernet/intel/ixgbevf/vf.c           | 125
>>>> ++++++++++++++++++++++
>>>>>>   drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>>>>>>   7 files changed, 243 insertions(+), 1 deletion(-)
>>>>> Remember to CC on patches against drivers in
>>>> drivers/net/ethernet/intel/ please.
>>>>
>>>> To CC who? ;)
>>>>
>>> Sorry, I fat fingered that response.  Please CC me.
>> Sure. NP.
>> Since we are talking already, could u comment on the RFC? Does it look
>> ok to you?
>>
>>
> I have provided feedback on 3 of the patches, the others look ok to me.
> I would like Greg Rose to look over your changes since he did most of
> the ixgbevf work, and I want to make sure that he is fine with these
> changes.

I saw them. Thanks, Jeff. I'll wait for Greg's comments before cooking 
the final series then.

Again, thanks for a rapid response.
