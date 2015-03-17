From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH 1/3] net: add support for phys_port_name
Date: Mon, 16 Mar 2015 21:29:37 -0600
Message-ID: <55079FA1.3040604@gmail.com>
References: <1426520818-11198-1-git-send-email-dsahern@gmail.com> <20150316160000.GD2058@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34773 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbCQD3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 23:29:38 -0400
Received: by iecsl2 with SMTP id sl2so187862557iec.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 20:29:37 -0700 (PDT)
In-Reply-To: <20150316160000.GD2058@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15 10:00 AM, Jiri Pirko wrote:
>> @@ -1159,6 +1168,8 @@ struct net_device_ops {
>> 						      bool new_carrier);
>> 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
>> 							struct netdev_phys_item_id *ppid);
>> +	int			(*ndo_get_phys_port_name)(struct net_device *dev,
>> +							  struct netdev_phys_item_name *name);
>
> I think that we do not need the structure. Just pass "char *name" for buffer
> where to put the name and "size_t len" for len of the buffer. Have:
> #define PORT_NAME_MAX_LEN 32
> and have called to have "char name[PORT_NAME_MAX_LEN]"
>
> Also, given that this is related to switches, won't it make sense to
> push this into switchdev code?


BTW, in regards to the latter comment phys_port_name should stay with 
phys_port_id which is currenly not a switchdev op.

David
