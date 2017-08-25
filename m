From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next:master 1328/1341]
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:77:3: error:
 'devlink_dpipe_header_ethernet' undeclared here (not in a function)
Date: Fri, 25 Aug 2017 09:28:23 +0200
Message-ID: <20170825072823.GA2023@nanopsycho>
References: <201708250859.0ROh3FDk%fengguang.wu@intel.com>
 <20170824.181150.1024909235376525254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fengguang.wu@intel.com, arkadis@mellanox.com, kbuild-all@01.org,
        netdev@vger.kernel.org, jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35130 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754403AbdHYH20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 03:28:26 -0400
Received: by mail-wr0-f195.google.com with SMTP id a47so953040wra.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 00:28:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170824.181150.1024909235376525254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 25, 2017 at 03:11:50AM CEST, davem@davemloft.net wrote:
>From: kbuild test robot <fengguang.wu@intel.com>
>Date: Fri, 25 Aug 2017 08:16:01 +0800
>
>> All error/warnings (new ones prefixed by >>):
>> 
>>>> drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:77:3: error: 'devlink_dpipe_header_ethernet' undeclared here (not in a function)
>>      &devlink_dpipe_header_ethernet,
>>       ^
>>>> drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:78:3: error: 'devlink_dpipe_header_ipv4' undeclared here (not in a function)
>>      &devlink_dpipe_header_ipv4,
>>       ^
>>    drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c: In function 'mlxsw_sp_dpipe_erif_table_init':
>>    drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:305:9: error: too few arguments to function 'devlink_dpipe_table_register'
>>      return devlink_dpipe_table_register(devlink,
>
>Jiri and co., I think you'll need some ifdef'ery to deal with this
>properly.

Will fix this. Thanks.
