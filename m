From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next 04/11] net: dsa: Add support for learning FDB
 through notification
Date: Wed, 19 Jul 2017 13:27:50 +0300
Message-ID: <f371f4fa-4b09-d342-9b17-647b49468330@mellanox.com>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
 <1500387624-4361-5-git-send-email-arkadis@mellanox.com>
 <87o9shfywl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0059.outbound.protection.outlook.com ([104.47.0.59]:15200
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754580AbdGSK2B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 06:28:01 -0400
In-Reply-To: <87o9shfywl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/18/2017 08:16 PM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> Arkadi Sharshevsky <arkadis@mellanox.com> writes:
> 
>> --- a/include/net/dsa.h
>> +++ b/include/net/dsa.h
>> @@ -451,6 +451,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
>>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>>  
>>  struct net_device *dsa_dev_to_net_device(struct device *dev);
>> +bool dsa_schedule_work(struct work_struct *work);
> 
> You forgot to move this declaration to net/dsa/dsa_priv.h, since this is
> private to DSA core and does not need to be exposed to drivers ;-)
>

No problem, will move it to dsa_priv.h, thanks.

>> +	err = unregister_netdevice_notifier(&dsa_slave_switchdev_notifier);
>> +	if (err)
>> +		pr_err("DSA: failed to unregister switchdev notifier (%d)\n", err);
> 
> I think you meant unregister_switchdev_notifier() here.
> 
> Thanks,
> 
>         Vivien
> 
