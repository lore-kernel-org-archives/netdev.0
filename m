From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/5] net: dsa: Remove master_netdev and use
 dst->cpu_dp->netdev
Date: Tue, 6 Jun 2017 11:09:01 -0700
Message-ID: <caae2343-19d5-eadd-94e5-7dfbe3e5c8bd@gmail.com>
References: <20170606170202.21491-1-f.fainelli@gmail.com>
 <20170606170202.21491-2-f.fainelli@gmail.com>
 <87d1ahjagr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34459 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbdFFSJF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:09:05 -0400
Received: by mail-qt0-f195.google.com with SMTP id o21so21331139qtb.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 11:09:04 -0700 (PDT)
In-Reply-To: <87d1ahjagr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 10:24 AM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> -	struct net_device *p = ds->dst[ds->index].master_netdev;
>> +	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;
> 
>                                ds->dst->cpu_dp->netdev
> 
> ds->dst is not an array anymore, lucky sf2 switch index is always 0 ;-)
> 
>>  	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
>>  	struct ethtool_wolinfo pwol;
>>  
>> @@ -829,7 +829,7 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
>>  static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
>>  			      struct ethtool_wolinfo *wol)
>>  {
>> -	struct net_device *p = ds->dst[ds->index].master_netdev;
>> +	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;
> 
> same here.

It's changed in patch 5, so I did not bother doing an intermediate
change considering we ditch this eventually.

Thanks!

> 
> Thanks,
> 
>         Vivien
> 


-- 
Florian
