From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 3/4] mlxsw: spectrum: router: Add support for
 address validator notifier
Date: Wed, 11 Oct 2017 09:19:42 -0600
Message-ID: <23a6d38a-e0a8-9f2a-bb75-7d5343f1f694@gmail.com>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-4-git-send-email-dsahern@gmail.com>
 <20171011135405.GB11653@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:47657 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752065AbdJKPTk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 11:19:40 -0400
Received: by mail-pg0-f50.google.com with SMTP id r25so1154161pgn.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 08:19:39 -0700 (PDT)
In-Reply-To: <20171011135405.GB11653@splinter>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/17 7:54 AM, Ido Schimmel wrote:
>> @@ -4533,7 +4541,9 @@ static int __init mlxsw_sp_module_init(void)
>>  	int err;
>>  
>>  	register_netdevice_notifier(&mlxsw_sp_netdevice_nb);
>> +	register_inetaddr_validator_notifier(&mlxsw_sp_inetaddr_valid_nb);
>>  	register_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
>> +	register_inet6addr_validator_notifier(&mlxsw_sp_inet6addr_valid_nb);
>>  	register_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
>>  	register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
> Need unregister in rollback and __exit function.
> 

oops, thanks for noticing that. Fixed and took care of your other comments.
