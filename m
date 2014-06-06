From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] net: use ethtool_cmd_speed_set helper to
 set ethtool speed value
Date: Fri, 6 Jun 2014 15:02:11 +0200
Message-ID: <20140606130211.GM2984@minipsycho.orion>
References: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
 <1402057021-12867-3-git-send-email-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6D17258956@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:50835 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaFFNCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 09:02:15 -0400
Received: by mail-we0-f171.google.com with SMTP id w62so2768909wes.2
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 06:02:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17258956@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 06, 2014 at 02:24:49PM CEST, David.Laight@ACULAB.COM wrote:
>From: Jiri Pirko
>...
>> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
>> @@ -141,6 +141,7 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
>>  	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
>>  	struct e1000_sfp_flags *eth_flags = &dev_spec->eth_flags;
>>  	u32 status;
>> +	u32 speed;
>...
>> +		speed = SPEED_UNKNOWN;
>
>SPEED_UNKNOWN is defined as -1

Correct.

static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep, __u32 speed)

>
>	David
>
>
>
