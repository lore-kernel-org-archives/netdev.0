From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/6] net: add netif_is_ovs_master helper with
 IFF_OPENVSWITCH private flag
Date: Thu, 27 Aug 2015 07:40:35 +0200
Message-ID: <20150827054035.GB2228@nanopsycho.orion>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
 <1440606998-11072-4-git-send-email-jiri@resnulli.us>
 <55DDF667.20801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, simon.horman@netronome.com,
	Jiri Pirko <jiri@mellanox.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38835 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbbH0Fki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 01:40:38 -0400
Received: by wicja10 with SMTP id ja10so33566327wic.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 22:40:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55DDF667.20801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 26, 2015 at 07:24:55PM CEST, f.fainelli@gmail.com wrote:
>On 26/08/15 09:36, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Add this helper so code can easily figure out if netdev is openswitch.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/linux/netdevice.h            | 8 ++++++++
>>  net/openvswitch/vport-internal_dev.c | 2 +-
>>  2 files changed, 9 insertions(+), 1 deletion(-)
>> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index be625f4..0a884e6 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1264,6 +1264,7 @@ struct net_device_ops {
>>   * @IFF_MACVLAN: Macvlan device
>>   * @IFF_VRF_MASTER: device is a VRF master
>>   * @IFF_NO_QUEUE: device can run without qdisc attached
>> + * @IFF_VRF_OPENVSWITCH: device is a Open vSwitch master
>
>Typo, the flag you introduced is named IFF_OPENVSWITCH, not VFR_OPENSWITCH.

Oups, will fix. Thanks
