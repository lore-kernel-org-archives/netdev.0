From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Wed, 19 Nov 2014 15:47:03 +0800
Message-ID: <CADvbK_e2DdWrXOA-zu0iTRxDLAuS_Ec-d597i8VTksD=PL4c+w@mail.gmail.com>
References: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
	<546B8093.4080507@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:53781 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837AbaKSHrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 02:47:05 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so859960wid.6
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 23:47:04 -0800 (PST)
In-Reply-To: <546B8093.4080507@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> ---
>>   net/ipv4/ip_vti.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
>> index 3e86101..1a7e979 100644
>> --- a/net/ipv4/ip_vti.c
>> +++ b/net/ipv4/ip_vti.c
>> @@ -528,6 +528,7 @@ static struct rtnl_link_ops vti_link_ops __read_mostly
>> = {
>>         .validate       = vti_tunnel_validate,
>>         .newlink        = vti_newlink,
>>         .changelink     = vti_changelink,
>> +       .dellink        = ip_tunnel_dellink,
>
> Nitpicking: other lines into this struct uses tabs to align the '=', but
> the one you add uses spaces.
>
>
okay, thanks, I will correct it.
