From: Phil Karn <karn@ka9q.net>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 08:28:41 -0800
Message-ID: <4D5BFB39.8070805@ka9q.net>
References: <4D5BADCF.5000804@ka9q.net>	<AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>	<4D5BF411.4020204@ka9q.net> <AANLkTikNrwd31RBj1gc6kSaT=qodS=A=YntM=72PMbDf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:38248 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656Ab1BPQ2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 11:28:46 -0500
Received: by pzk35 with SMTP id 35so220873pzk.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 08:28:46 -0800 (PST)
In-Reply-To: <AANLkTikNrwd31RBj1gc6kSaT=qodS=A=YntM=72PMbDf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/11 8:10 AM, richard -rw- weinberger wrote:
> On Wed, Feb 16, 2011 at 4:58 PM, Phil Karn <karn@ka9q.net> wrote:
>> On 2/16/11 4:51 AM, richard -rw- weinberger wrote:
>>> On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wrote:
>>>> The range check on vlan_id in register_vlan_device is off by one, and it
>>>> prevents the creation of a vlan interface for vlan ID 4095. (OSX allows
>>>> this, I checked.)
>>>
>>> Then OSX should fix their code. 4095 is reserved.
>>>
>>
>> If it's reserved, then it's up to the user to reserve it.
> 
> No.
> 
> See:
> http://standards.ieee.org/getieee802/download/802.1Q-2005.pdf
> 

Well, then I guess we all know better than the user. That's the Windows
Way...no, wait, I thought this is Linux.

The fact is that I did encounter a misconfigured switch using vlan 4095,
and because of this off-by-one error I was unable to talk to it and fix it.

I was hoping I wouldn't have to patch every new kernel I install.

