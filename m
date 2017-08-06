From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next v2 00/13] Change DSA's FDB API and perform
 switchdev cleanup
Date: Sun, 6 Aug 2017 16:07:08 +0300
Message-ID: <984b4d3e-c9c4-545a-280b-0673227136a5@mellanox.com>
References: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
 <87mv80ji63.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <099a0552-0139-20d4-2529-c1202303d772@mellanox.com>
 <87pocvnkfw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <ede22100-3a66-f54d-a618-a3b840a2664c@mellanox.com>
 <aa4f3dc5-6693-4de8-5191-f0a939ff8168@mellanox.com>
 <20170804052301.GA1906@nanopsycho.orion>
 <87d18b2vy4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0065.outbound.protection.outlook.com ([104.47.1.65]:62769
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751256AbdHFNHR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 6 Aug 2017 09:07:17 -0400
In-Reply-To: <87d18b2vy4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/04/2017 06:29 PM, Vivien Didelot wrote:
> Hi Arkadi, Jiri,
> 
> Jiri Pirko <jiri@resnulli.us> writes:
> 
>>> It seems impossible currently to move the self to be the default, and
>>> this introduces regression which you don't approve, so it seems few
>>> options left:
>>>
>>> a) Leave two ways to add fdb, through the bridge (by using the master
>>>   flag) which is introduced in this patchset, and by using the self
>>>   which is the legacy way. In this way no regression will be introduced,
>>>   yet, it feels confusing a bit. The benefit is that we (DSA/mlxsw)
>>>   will be synced.
>>> b) Leave only the self (which means removing patch no 4,5).
>>
>> I belive that option a) is the correct way to go. Introduction of self
>> inclusion was a mistake from the very beginning. I think that we should
>> just move one and correct this mistake.
>>
>> Vivien, any arguments against a)?
> 
> I do agree with a). Arkadi, when moving switchdev implementations inside
> of DSA core, can I ask you to move the ones considered as the legacy way
> into legacy.c and ideally comment it? Configuration from userspace is
> still very confusing and this will remind us to get rid of it one day.
> 
> 
> Thanks,
> 
>         Vivien
> 

Yeah, no problem.

Thanks,
Arkadi
