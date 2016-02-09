From: "Fastabend, John R" <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Tue, 9 Feb 2016 03:27:29 -0800
Message-ID: <56B9CD21.6010305@gmail.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092959.1356.91778.stgit@john-Precision-Tower-5810>
 <20160204073050.GA31753@office.Home> <56B30A66.80206@gmail.com>
 <20160204121209.GA32335@office.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jiri@resnulli.us, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: "Amir Vadai\"" <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33367 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932974AbcBIL1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 06:27:42 -0500
Received: by mail-ob0-f169.google.com with SMTP id is5so181990639obc.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 03:27:41 -0800 (PST)
In-Reply-To: <20160204121209.GA32335@office.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> Ah I should have annotated this in the commit msg. I turn the feature
>> off by default to enable it the user needs to run
>>
>> 	# ethtool -K ethx hw-tc-offload on
>>
>> this is just a habit of mine to leave new features off by default for
>> a bit until I work out some of the kinks. For example I found a case
>> today where if you build loops into your u32 graph the hardware tables
>> can get out of sync with the software tables. This is sort of extreme
>> corner case not sure if anyone would really use u32 but it is valid
>> and the hardware should abort correctly.
> Yeh - that is nice :) But I was just pointing out on a small typo which I
> think you have.
> The new case will never happen. You compare: (features & NETIF_F_NTUPLE) == NETIF_F_HW_TC
> Also the comment before the switch should be modified.

Aha nice catch my scripts were enabling both ntuple and hw-tc-offload
for testing compatibility issues. I wonder if there is a bug somewhere
else though that checks that code most likely because it was definately
getting offloaded.

Good catch again thanks.

> 
>>
>> Thanks,
>> John
>>
