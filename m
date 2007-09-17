From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] Rename struct net to struct netns
Date: Mon, 17 Sep 2007 17:40:13 +0200
Message-ID: <46EE9FDD.3090807@bull.net>
References: <46EE932F.2030206@openvz.org> <46EE964E.7050901@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:53002 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbXIQPnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 11:43:14 -0400
In-Reply-To: <46EE964E.7050901@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano wrote:
> Pavel Emelyanov wrote:
>> The name struct net is too generic. There already were
>> some people who wanted to have some better name (for
>> easier grep for example). I propose the struct netns one.
>>
>> The patch is (already) huge (sorry), but it's nothing but
>>   sed -e s/struct net\>/struct netns/g
>>
>> If this name is bad as well, let's select a new one
>> before the struct net floods the kernel.
> 
> [ SNIP ]
> 
>> --- a/include/linux/nsproxy.h
>> +++ b/include/linux/nsproxy.h
>> @@ -29,7 +29,7 @@ struct nsproxy {
>>      struct mnt_namespace *mnt_ns;
>>      struct pid_namespace *pid_ns;
>>      struct user_namespace *user_ns;
>> -    struct net          *net_ns;
>> +    struct netns          *net_ns;
> 
> IMHO, if we want to be consistent with all the rest of the namespaces,
> that should be net_namespace.

Sure it's a good argument. 
But I find that 'net', although it is an uber generic name, 
represents its contents appropriately: its function is to store
all data for a network stack, so it is what represent a network
in the kernel.

Anyway, if we want to change it, I think net_namespace is better
than netns because of the consistency argument given by Daniel.
(But it's longer :( )

Just my 2 cents.

Benjamin


> 
> [ SNIP ]


> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

   http://www.bull.com
