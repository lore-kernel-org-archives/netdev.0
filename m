From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: miss section in menuconfig generator?
Date: Tue, 22 Apr 2008 14:47:56 +0400
Message-ID: <480DC25C.4090707@bigtelecom.ru>
References: <480DB039.3040906@bigtelecom.ru> <480DB9F4.2010809@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:56507 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994AbYDVKsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 06:48:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 1426BA6C5C6
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 14:48:04 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id o9hbkAAqkSEh for <netdev@vger.kernel.org>;
	Tue, 22 Apr 2008 14:47:57 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id F3EDBA6C5B8
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 14:47:56 +0400 (MSD)
In-Reply-To: <480DB9F4.2010809@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I understand.
This values are hidden. And get values from "default NF_NAT && 
NF_CONNTRACK_PPTP" if "user not set this values".
But my config have this values from older config version (make 
menuconfig) and not set it again that i change NF_CONNTRACK_PPTP to 
Y/N.  Also if i one time save config - it write value of hidden param (i 
say about CONFIG_NF_NAT_PPTP now).
Have i chance to reconfig this value if menuconfig set it 1 time for me?

Thanks!


> I found.
> its becouse in file ./net/ipv4/netfilter/Kconfig all this options have 
> NULL "tristate" like this:
>
> config NF_NAT_PROTO_GRE
>        tristate
>        depends on NF_NAT && NF_CT_PROTO_GRE
>
> Is that normal? How to compile that parts in kernel (not modules)?
>
> Thanks!
>
>> Hello all. Sorry if its not bug.
>>
>> look to section "IP: Netfilter Configuration" in .config i see values 
>> like this:
>> CONFIG_NF_NAT_PROTO_GRE=m
>>
>> but in menuconfig i can find it in this section ("network->Network 
>> packet filtering framework->IP: Netfilter Configuration"). its 
>> blackhole? =)
>>
>> I attach my config.
>>
>> Thanks all
>>
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

