From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next RFC 04/12] net: dsa: Add ordered workqueue
Date: Sun, 9 Jul 2017 15:56:50 +0300
Message-ID: <b70d98f1-484a-db06-ebeb-5e1b8582db74@mellanox.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-5-git-send-email-arkadis@mellanox.com>
 <6db9cee1-8f2c-e086-55e6-d70b69c3824e@gmail.com>
 <87lgo1cslu.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00075.outbound.protection.outlook.com ([40.107.0.75]:4352
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752081AbdGIM47 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Jul 2017 08:56:59 -0400
In-Reply-To: <87lgo1cslu.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/06/2017 09:45 PM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
>>> This workqueue will be used for FDB add/del processing. It should
>>> be destroyed after all devices unregistered successfully.
>>>
>>> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
>>> ---
>>>  include/net/dsa.h |  1 +
>>>  net/dsa/dsa.c     | 13 +++++++++++++
>>>  2 files changed, 14 insertions(+)
>>>
>>> diff --git a/include/net/dsa.h b/include/net/dsa.h
>>> index f054d41..4835b0e 100644
>>> --- a/include/net/dsa.h
>>> +++ b/include/net/dsa.h
>>> @@ -451,6 +451,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
>>>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>>>  
>>>  struct net_device *dsa_dev_to_net_device(struct device *dev);
>>> +bool dsa_schedule_work(struct work_struct *work);
>>
>> I'd move this to dsa_priv.h in net/dsa/ because it is not supposed to be
>> used by DSA drivers.
>>
>> You may also consider squashing this into the next patch since in itself
>> it's not used just yet.
> 
> I agree with Florian on this. Even though it'll make the next patch a
> bit bigger, it'll make it easier to understand the whole workqueue
> processing logic.
> 
> Thanks,
> 
>         Vivien
> 

Ok no problem, will squash.
Thanks
